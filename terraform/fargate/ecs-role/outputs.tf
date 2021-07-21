output "role_arn" {
  value = aws_iam_role.ecs_task_execution.arn
}
output "secret_arn" {
  value = aws_secretsmanager_secret_version.repo_secret.arn
}
