variable "name" {
  description = "Name of the ECS service and family."
  type        = string
}

variable "cluster_id" {
  description = "The ID of the ECS cluster."
  type        = string
}

variable "cluster_name" {
  description = "The name of the ECS cluster (required for autoscaling)."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the security group will be created."
  type        = string
}

variable "subnets" {
  description = "List of private subnets for the ECS service."
  type        = list(string)
}

variable "task_execution_role_arn" {
  description = "Execution role ARN for the ECS task definition."
  type        = string
}

variable "cpu" {
  description = "The number of CPU units used by the task (e.g. 256, 512, 1024)."
  type        = number
  default     = 256
}

variable "memory" {
  description = "The amount of memory (in MiB) used by the task (e.g. 512, 1024, 2048)."
  type        = number
  default     = 512
}

variable "container_image" {
  description = "The container image to deploy."
  type        = string
}

variable "container_port" {
  description = "The port the container listens on."
  type        = number
}

variable "environment_variables" {
  description = "List of environment variables for the container."
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group."
  type        = string
}

variable "aws_region" {
  description = "AWS region for CloudWatch logging."
  type        = string
  default     = "us-east-1"
}

variable "allowed_ingress_security_groups" {
  description = "Map of security group IDs allowed to access the service, along with ports."
  type = list(object({
    security_group_id = string
    port              = number
  }))
  default = []
}

variable "target_group_arn" {
  description = "The ARN of the Application Load Balancer Target Group (optional)."
  type        = string
  default     = ""
}

variable "service_registry_arn" {
  description = "The ARN of the AWS Cloud Map service registry (optional)."
  type        = string
  default     = ""
}

variable "desired_count" {
  description = "Desired number of running tasks."
  type        = number
  default     = 2
}

variable "health_check_command" {
  description = "Command to run for the container health check (optional)."
  type        = list(string)
  default     = []
}

variable "enable_autoscaling" {
  description = "Enable target tracking CPU autoscaling for this service."
  type        = bool
  default     = false
}

variable "min_capacity" {
  description = "Minimum capacity for autoscaling."
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum capacity for autoscaling."
  type        = number
  default     = 10
}

variable "cpu_target_value" {
  description = "Target value for CPU utilization autoscaling policy."
  type        = number
  default     = 70
}

variable "db_target_group_arn" {
  description = "ARN of the NLB target group for the database (optional)."
  type        = string
  default     = ""
}
