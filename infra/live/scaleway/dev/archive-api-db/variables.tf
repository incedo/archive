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
  description = "Scaleway region for Secret Manager and RDB."
  type        = string
  default     = "nl-ams"
}

variable "scaleway_zone" {
  description = "Scaleway zone used when zonal resources are needed."
  type        = string
  default     = "nl-ams-1"
}

variable "service_name" {
  description = "Logical service name for naming shared DB resources."
  type        = string
  default     = "archive-api"
}

variable "private_network_name" {
  description = "Optional explicit private network name."
  type        = string
  default     = null
}

variable "private_network_subnet_cidr" {
  description = "IPv4 subnet reserved for the private network."
  type        = string
  default     = "172.16.0.0/24"
}

variable "db_name" {
  description = "Database name provisioned for archive-api."
  type        = string
  default     = "archive"
}

variable "db_username" {
  description = "Database username provisioned for archive-api."
  type        = string
  default     = "archive"
}

variable "db_engine" {
  description = "Scaleway RDB engine identifier."
  type        = string
  default     = "PostgreSQL-16"
}

variable "db_node_type" {
  description = "Scaleway RDB node type."
  type        = string
  default     = "DB-DEV-S"
}

variable "db_is_ha_cluster" {
  description = "Whether the database is provisioned as HA."
  type        = bool
  default     = false
}

variable "db_disable_backup" {
  description = "Whether automatic backups are disabled."
  type        = bool
  default     = false
}

variable "db_backup_schedule_frequency_hours" {
  description = "Backup frequency in hours when backups are enabled."
  type        = number
  default     = 24
}

variable "db_backup_schedule_retention_days" {
  description = "Backup retention in days when backups are enabled."
  type        = number
  default     = 1
}

variable "description" {
  description = "Optional description for the Scaleway DB resources."
  type        = string
  default     = "Archive API optional dev PostgreSQL on Scaleway"
}

variable "tags" {
  description = "Additional tags applied to Scaleway resources."
  type        = list(string)
  default     = []
}
