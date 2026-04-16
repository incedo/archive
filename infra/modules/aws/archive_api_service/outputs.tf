output "ecr_repository_name" {
  description = "ECR repository name used for archive-api images."
  value       = aws_ecr_repository.this.name
}

output "ecr_repository_url" {
  description = "ECR repository URL used by CI/CD."
  value       = aws_ecr_repository.this.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN used by CI/CD permissions."
  value       = aws_ecr_repository.this.arn
}

output "ecs_cluster_name" {
  description = "ECS cluster name for the runtime."
  value       = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  description = "ECS service name for archive-api."
  value       = aws_ecs_service.this.name
}

output "ecs_task_family" {
  description = "ECS task definition family."
  value       = aws_ecs_task_definition.this.family
}

output "ecs_container_name" {
  description = "Container name inside the task definition."
  value       = var.container_name
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group for archive-api runtime logs."
  value       = aws_cloudwatch_log_group.this.name
}

output "execution_role_arn" {
  description = "IAM role ARN used by ECS task execution."
  value       = aws_iam_role.execution.arn
}

output "task_role_arn" {
  description = "IAM role ARN used by the application container."
  value       = aws_iam_role.task.arn
}
