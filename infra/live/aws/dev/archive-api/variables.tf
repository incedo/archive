variable "project_name" {
  description = "Stable project identifier used for naming."
  type        = string
  default     = "archive"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "availability_zones" {
  description = "Optional explicit availability zones for public subnets."
  type        = list(string)
  default     = []
}

variable "service_name" {
  description = "Logical service name."
  type        = string
  default     = "archive-api"
}

variable "container_name" {
  description = "ECS container definition name."
  type        = string
  default     = "archive-api"
}

variable "image_uri" {
  description = "Bootstrap image URI for the ECS task definition."
  type        = string
  default     = "public.ecr.aws/docker/library/nginx:stable-alpine"
}

variable "vpc_cidr" {
  description = "CIDR block for the AWS dev VPC."
  type        = string
  default     = "10.42.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets used by ECS tasks."
  type        = list(string)
  default     = ["10.42.1.0/24", "10.42.2.0/24"]
}

variable "allowed_ingress_cidrs" {
  description = "CIDR blocks allowed to reach archive-api directly on port 8080."
  type        = list(string)
  default     = []
}

variable "jdbc_url" {
  description = "JDBC URL stored in Secrets Manager for archive-api."
  type        = string
  default     = "jdbc:postgresql://replace-me:5432/archive"
}

variable "jdbc_user" {
  description = "JDBC user stored in Secrets Manager for archive-api."
  type        = string
  default     = "archive"
}

variable "jdbc_password" {
  description = "JDBC password stored in Secrets Manager for archive-api."
  type        = string
  default     = "replace-me"
}

variable "assign_public_ip" {
  description = "Whether the ECS service assigns public IPs."
  type        = bool
  default     = true
}

variable "desired_count" {
  description = "Desired number of tasks."
  type        = number
  default     = 0
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

variable "log_retention_in_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 14
}

variable "target_group_arn" {
  description = "Optional target group ARN for load balanced ingress."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags applied to the stack."
  type        = map(string)
  default     = {}
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the AWS deploy role, in owner/name form."
  type        = string
  default     = "incedo/archive"
}

variable "github_environment_name" {
  description = "GitHub Actions environment name allowed to assume the AWS deploy role."
  type        = string
  default     = "dev"
}

variable "github_oidc_provider_thumbprints" {
  description = "Thumbprints for the GitHub Actions OIDC provider."
  type        = list(string)
  default     = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

variable "github_deploy_role_name" {
  description = "IAM role name used by GitHub Actions for AWS deployments."
  type        = string
  default     = null
}
