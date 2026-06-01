locals {
  name = "${var.project_name}-${var.environment}"

  container_ports = {
    frontend = 80
    backend  = 3001
    db       = 3306
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Activity    = "3.2"
  }
}
