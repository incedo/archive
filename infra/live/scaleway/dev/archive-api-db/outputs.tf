output "scaleway_project_id" {
  value = var.scaleway_project_id
}

output "scaleway_region" {
  value = var.scaleway_region
}

output "scaleway_zone" {
  value = var.scaleway_zone
}

output "private_network_name" {
  value = scaleway_vpc_private_network.archive_api.name
}

output "private_network_id" {
  value = scaleway_vpc_private_network.archive_api.id
}

output "database_instance_name" {
  value = scaleway_rdb_instance.postgres.name
}

output "database_instance_id" {
  value = scaleway_rdb_instance.postgres.id
}

output "database_name" {
  value = var.db_name
}

output "database_username" {
  value = var.db_username
}

output "database_private_ip" {
  value = scaleway_rdb_instance.postgres.private_network[0].ip
}

output "database_port" {
  value = scaleway_rdb_instance.postgres.private_network[0].port
}

output "jdbc_url" {
  value     = "jdbc:postgresql://${scaleway_rdb_instance.postgres.private_network[0].ip}:${scaleway_rdb_instance.postgres.private_network[0].port}/${var.db_name}"
  sensitive = true
}

output "jdbc_user" {
  value     = var.db_username
  sensitive = true
}

output "jdbc_password" {
  value     = random_password.postgres.result
  sensitive = true
}

output "jdbc_secret_name" {
  value = scaleway_secret.jdbc.name
}

output "jdbc_secret_id" {
  value = scaleway_secret.jdbc.id
}

output "jdbc_secret_path" {
  value = scaleway_secret.jdbc.path
}
