output "scaleway_project_id" {
  value = var.scaleway_project_id
}

output "scaleway_region" {
  value = var.scaleway_region
}

output "scaleway_zone" {
  value = var.scaleway_zone
}

output "container_namespace_name" {
  value = local.container_namespace
}

output "container_name" {
  value = var.container_name
}

output "container_id" {
  value = scaleway_container.archive_api.id
}

output "container_registry_endpoint" {
  value = scaleway_container_namespace.archive_api.registry_endpoint
}

output "container_domain_name" {
  value = scaleway_container.archive_api.domain_name
}

output "container_url" {
  value = "https://${scaleway_container.archive_api.domain_name}"
}

output "private_network_id" {
  value = var.private_network_id
}

output "bootstrap_image_reference" {
  value = scaleway_container.archive_api.registry_image
}
