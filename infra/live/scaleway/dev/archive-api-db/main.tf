provider "scaleway" {
  project_id = var.scaleway_project_id
  region     = var.scaleway_region
  zone       = var.scaleway_zone
}

locals {
  name_prefix          = "${var.project_name}-${var.environment}"
  private_network_name = coalesce(var.private_network_name, "${local.name_prefix}-private")
  rdb_instance_name    = "${local.name_prefix}-${var.service_name}-db"
  common_tags          = concat(["project:${var.project_name}", "environment:${var.environment}", "service:${var.service_name}"], var.tags)
}

resource "random_password" "postgres" {
  length  = 24
  special = true
}

resource "scaleway_vpc_private_network" "archive_api" {
  name       = local.private_network_name
  project_id = var.scaleway_project_id
  region     = var.scaleway_region
  tags       = local.common_tags

  ipv4_subnet {
    subnet = var.private_network_subnet_cidr
  }
}

resource "scaleway_secret" "jdbc" {
  name        = "jdbc"
  path        = "/${local.name_prefix}/${var.service_name}"
  description = "JDBC runtime contract for ${var.service_name}"
  project_id  = var.scaleway_project_id
  region      = var.scaleway_region
  tags        = local.common_tags
}

resource "scaleway_rdb_instance" "postgres" {
  name                      = local.rdb_instance_name
  project_id                = var.scaleway_project_id
  region                    = var.scaleway_region
  node_type                 = var.db_node_type
  engine                    = var.db_engine
  is_ha_cluster             = var.db_is_ha_cluster
  disable_backup            = var.db_disable_backup
  backup_schedule_frequency = var.db_backup_schedule_frequency_hours
  backup_schedule_retention = var.db_backup_schedule_retention_days
  user_name                 = var.db_username
  password                  = random_password.postgres.result
  tags                      = local.common_tags

  private_network {
    pn_id       = scaleway_vpc_private_network.archive_api.id
    enable_ipam = true
  }
}

resource "scaleway_secret_version" "jdbc" {
  secret_id   = scaleway_secret.jdbc.id
  description = "Current JDBC values for ${var.service_name}"
  region      = var.scaleway_region
  data = jsonencode({
    ARCHIVE_JDBC_URL      = "jdbc:postgresql://${scaleway_rdb_instance.postgres.private_network[0].ip}:${scaleway_rdb_instance.postgres.private_network[0].port}/${var.db_name}"
    ARCHIVE_JDBC_USER     = var.db_username
    ARCHIVE_JDBC_PASSWORD = random_password.postgres.result
  })
}
