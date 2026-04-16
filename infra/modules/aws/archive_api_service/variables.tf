variable "project_name" {
  description = "Stable project identifier used for naming."
  type        = string
}

variable "environment" {
  description = "Environment name such as dev, test, or prod."
  type        = string
}

variable "aws_region" {
  description = "AWS region for the runtime resources."
  type        = string
}

variable "service_name" {
  description = "Logical service name, used for ECR, ECS service, and task family naming."
  type        = string
  default     = "archive-api"
}

variable "container_name" {
  description = "Container name inside the ECS task definition."
  type        = string
  default     = "archive-api"
}

variable "image_uri" {
  description = "Bootstrap image URI for the ECS task definition."
  type        = string
}

variable "container_port" {
  description = "Container port exposed by the application."
  type        = number
  default     = 8080
}

variable "desired_count" {
  description = "Desired number of ECS tasks."
  type        = number
  default     = 1
}

variable "cpu" {
  description = "Task CPU units."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Task memory in MiB."
  type        = number
  default     = 512
}

variable "subnet_ids" {
  description = "Subnet IDs used by the ECS service."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs attached to the ECS service."
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Whether ECS tasks receive public IPs."
  type        = bool
  default     = false
}

variable "jdbc_secret_arn" {
  description = "Secrets Manager ARN that stores ARCHIVE_JDBC_URL, ARCHIVE_JDBC_USER, and ARCHIVE_JDBC_PASSWORD."
  type        = string
}

variable "log_retention_in_days" {
  description = "CloudWatch log retention period."
  type        = number
  default     = 14
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "target_group_arn" {
  description = "Optional target group ARN for load-balanced deployments."
  type        = string
  default     = null
}

