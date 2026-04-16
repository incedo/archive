output "aws_region" {
  value = var.aws_region
}

output "identity_center_instance_arns" {
  value = data.aws_ssoadmin_instances.this.arns
}

output "identity_center_identity_store_ids" {
  value = data.aws_ssoadmin_instances.this.identity_store_ids
}

