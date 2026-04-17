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

variable "scaleway_project_id" {
  description = "Scaleway project ID used for the stack."
  type        = string
}

variable "scaleway_region" {
  description = "Scaleway region for Serverless Containers and RDB."
  type        = string
  default     = "nl-ams"
}

variable "scaleway_zone" {
  description = "Scaleway zone used when zonal resources are needed."
  type        = string
  default     = "nl-ams-1"
}

variable "service_name" {
  description = "Logical service name."
  type        = string
  default     = "archive-api"
}

variable "container_name" {
  description = "Scaleway Serverless Container name."
  type        = string
  default     = "archive-api"
}

variable "container_port" {
  description = "Application port exposed by archive-api."
  type        = number
  default     = 8080
}

variable "image_reference" {
  description = "Bootstrap image reference for the first Scaleway deployment."
  type        = string
  default     = "docker.io/library/nginx:stable-alpine"
}

variable "min_scale" {
  description = "Minimum number of container instances."
  type        = number
  default     = 0
}

variable "max_scale" {
  description = "Maximum number of container instances."
  type        = number
  default     = 1
}

variable "cpu_limit" {
  description = "Container CPU limit in millicores for Serverless Containers."
  type        = number
  default     = 280
}

variable "memory_limit" {
  description = "Container memory limit in MiB for Serverless Containers."
  type        = number
  default     = 512
}

variable "privacy" {
  description = "Scaleway container privacy policy."
  type        = string
  default     = "public"
}

variable "timeout" {
  description = "Maximum request duration in seconds for the Serverless Container."
  type        = number
  default     = 300
}

variable "max_concurrency" {
  description = "Maximum concurrent requests per container instance."
  type        = number
  default     = 80
}

variable "protocol" {
  description = "Container protocol."
  type        = string
  default     = "http1"
}

variable "http_option" {
  description = "Whether HTTP is enabled directly or redirected to HTTPS."
  type        = string
  default     = "enabled"
}

variable "health_check_path" {
  description = "HTTP path used for container health checks."
  type        = string
  default     = "/api/v1/admin/health"
}

variable "health_check_interval" {
  description = "Health check interval in Go duration format."
  type        = string
  default     = "10s"
}

variable "health_check_failure_threshold" {
  description = "Number of failed health checks before marking the deployment unhealthy."
  type        = number
  default     = 6
}

variable "description" {
  description = "Optional description for the Scaleway runtime resources."
  type        = string
  default     = "Archive API dev runtime on Scaleway"
}

variable "private_network_id" {
  description = "Optional Private Network ID for archive-api when a separate DB/network stack exists."
  type        = string
  default     = null
}

variable "jdbc_url" {
  description = "Optional JDBC URL. Leave null for in-memory runtime."
  type        = string
  default     = null
  sensitive   = true
}

variable "jdbc_user" {
  description = "Optional JDBC username. Leave null for in-memory runtime."
  type        = string
  default     = null
  sensitive   = true
}

variable "jdbc_password" {
  description = "Optional JDBC password. Leave null for in-memory runtime."
  type        = string
  default     = null
  sensitive   = true
}

variable "tags" {
  description = "Additional tags applied to Scaleway resources."
  type        = list(string)
  default     = []
}
