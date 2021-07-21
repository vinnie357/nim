## registry
output "nim-plus-url" {
  value = aws_ecr_repository.nim-plus.repository_url
}

output "nginx-plus-url" {
  value = aws_ecr_repository.nginx-plus.repository_url
}
