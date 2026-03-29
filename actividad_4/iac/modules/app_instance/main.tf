locals {
  project_name = var.project_name
  environment  = var.environment
  owner_name   = var.owner_name
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.security_group_id]
  user_data_base64            = var.user_data
  user_data_replace_on_change = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.ebs_volume_size
    delete_on_termination = true
  }

  tags = {
    Name        = "${local.project_name}-${local.environment}-${var.app_name}"
    Project     = local.project_name
    Environment = local.environment
    Owner       = local.owner_name
    App         = var.app_name
  }
}

resource "aws_ebs_volume" "app_data" {
  availability_zone = aws_instance.app.availability_zone
  size              = var.ebs_data_volume_size
  type              = "gp3"

  tags = {
    Name        = "${local.project_name}-${local.environment}-${var.app_name}-data"
    Project     = local.project_name
    Environment = local.environment
    Owner       = local.owner_name
    App         = var.app_name
  }
}

resource "aws_volume_attachment" "app_data_attachment" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.app_data.id
  instance_id = aws_instance.app.id
}
