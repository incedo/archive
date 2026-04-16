output "aws_region" {
  value = var.aws_region
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "archive_api_security_group_id" {
  value = aws_security_group.archive_api.id
}

output "jdbc_secret_arn" {
  value = aws_secretsmanager_secret.jdbc.arn
}

output "ecr_repository_name" {
  value = module.archive_api_service.ecr_repository_name
}

output "ecr_repository_url" {
  value = module.archive_api_service.ecr_repository_url
}

output "ecs_cluster_name" {
  value = module.archive_api_service.ecs_cluster_name
}

output "ecs_service_name" {
  value = module.archive_api_service.ecs_service_name
}

output "ecs_task_family" {
  value = module.archive_api_service.ecs_task_family
}

output "ecs_container_name" {
  value = module.archive_api_service.ecs_container_name
}

output "cloudwatch_log_group_name" {
  value = module.archive_api_service.cloudwatch_log_group_name
}

output "github_actions_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github_actions.arn
}

output "github_actions_deploy_role_arn" {
  value = aws_iam_role.github_actions_deploy.arn
}
