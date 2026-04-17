provider "scaleway" {
  project_id = var.scaleway_project_id
  region     = var.scaleway_region
  zone       = var.scaleway_zone
}

locals {
  name_prefix         = "${var.project_name}-${var.environment}"
  container_namespace = "${local.name_prefix}-${var.service_name}"
  common_tags         = concat(["project:${var.project_name}", "environment:${var.environment}", "service:${var.service_name}"], var.tags)
  jdbc_env = {
    for key, value in {
      ARCHIVE_JDBC_URL      = var.jdbc_url
      ARCHIVE_JDBC_USER     = var.jdbc_user
      ARCHIVE_JDBC_PASSWORD = var.jdbc_password
    } : key => value if value != null && value != ""
  }
}

resource "scaleway_container_namespace" "archive_api" {
  name        = local.container_namespace
  description = var.description
  project_id  = var.scaleway_project_id
  region      = var.scaleway_region
  tags        = local.common_tags
}

resource "scaleway_container" "archive_api" {
  name         = var.container_name
  description  = var.description
  namespace_id = scaleway_container_namespace.archive_api.id
  registry_image = var.image_reference
  port         = var.container_port
  cpu_limit    = var.cpu_limit
  memory_limit = var.memory_limit
  min_scale    = var.min_scale
  max_scale    = var.max_scale
  timeout      = var.timeout
  privacy      = var.privacy
  protocol     = var.protocol
  http_option  = var.http_option
  deploy       = true
  tags         = local.common_tags
  private_network_id = var.private_network_id

  environment_variables = {
    ARCHIVE_PORT = tostring(var.container_port)
  }

  secret_environment_variables = local.jdbc_env

  health_check {
    failure_threshold = var.health_check_failure_threshold
    interval          = var.health_check_interval

    http {
      path = var.health_check_path
    }
  }

  scaling_option {
    concurrent_requests_threshold = var.max_concurrency
  }
}
