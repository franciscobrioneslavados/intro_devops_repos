provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = {
      Environment        = var.stage
      ProjectName        = var.project_name
      OrganizationalUnit = var.organizational_unit
      Description        = var.description
      ManagedBy          = var.managed_by
    }
  }
}

data "aws_availability_zones" "this" {
  state = "available"
}

locals {
  vpc_cidr = var.vpc_cidr

  # slice(list, start, end) Selects elements from start (inclusive) to end (exclusive).
  # Used to select the first 2 availability zones
  azs = slice(data.aws_availability_zones.this.names, 0, 2)
}

resource "aws_vpc" "this" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default" # default = multi-tenant, dedicated = single-tenant 

  tags = {
    Name = "vpc-${var.project_name}-${var.stage}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "igw-${var.project_name}-${var.stage}"
  }
}

resource "aws_subnet" "public_subnet" {
  count  = length(local.azs)
  vpc_id = aws_vpc.this.id
  # cidrsubnet(base_cidr, newbits, index)
  # newbits: number of bits to add to the base_cidr
  # index: index of the subnet
  # calculate the CIDR block for each subnet
  # 16 bits for the VPC CIDR block (2^16 = 65536 subnets)
  # 8 bits for the subnet CIDR block (2^8 = 256 subnets)
  # 24 bits for the host CIDR block (2^24 = 16777216 hosts)
  # 256 subnets
  # 256 hosts per subnet
  # example: cidrsubnet("10.0.0.0/16", 8, 0) -> "10.0.0.0/24" total 256 subnets
  # example: cidrsubnet("10.0.0.0/16", 8, 1) -> "10.0.1.0/24" total 256 subnets
  # example: cidrsubnet("10.0.0.0/16", 8, 2) -> "10.0.2.0/24" total 256 subnets
  cidr_block              = cidrsubnet(local.vpc_cidr, var.subnet_newbits, count.index)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-public-${var.project_name}-${var.stage}-${count.index}"
    Tier = "web-tier"
  }
}

resource "aws_subnet" "private_subnet" {
  count                   = length(local.azs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(local.vpc_cidr, var.subnet_newbits, count.index + length(local.azs))
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "subnet-private-${var.project_name}-${var.stage}-${count.index}"
    Tier = "app-tier"
  }
}

resource "aws_subnet" "database_subnet" {
  count  = length(local.azs)
  vpc_id = aws_vpc.this.id

  # Agregamos un offset del doble de las subredes públicas (length * 2)
  # para que tomen los índices 4 y 5.
  cidr_block              = cidrsubnet(local.vpc_cidr, var.subnet_newbits, count.index + (length(local.azs) * 2))
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-database-${var.project_name}-${var.stage}-${count.index}"
    Tier = "database-tier"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = {
    Name = "route-table-public-${var.project_name}-${var.stage}"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  count  = var.nat_per_az ? length(local.azs) : 1
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }
  tags = {
    Name = "route-table-private-${var.project_name}-${var.stage}"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = var.nat_per_az ? aws_route_table.private_route_table[count.index].id : aws_route_table.private_route_table[0].id
}

resource "aws_route_table_association" "database_route_table_association" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.database_subnet[count.index].id
  route_table_id = var.nat_per_az ? aws_route_table.private_route_table[count.index].id : aws_route_table.private_route_table[0].id
}

resource "aws_eip" "this" {
  count  = var.nat_per_az ? length(local.azs) : 1
  domain = "vpc"

  depends_on = [aws_internet_gateway.this]

  tags = {
    Name = "eip-nat-gateway-${var.project_name}-${var.stage}"
  }
}

resource "aws_nat_gateway" "this" {
  count         = var.nat_per_az ? length(local.azs) : 1
  subnet_id     = aws_subnet.public_subnet[count.index].id # NAT Gateway must be in a public subnet
  allocation_id = aws_eip.this[count.index].id             # EIP must be created before NAT Gateway

  tags = {
    Name = "nat-gateway-${var.project_name}-${var.stage}"
  }
}



