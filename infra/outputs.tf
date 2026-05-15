output "backend_ecr" {
  value = aws_ecr_repository.backend.repository_url
}
output "frontend_ecr" {
  value = aws_ecr_repository.frontend.repository_url
}
output "mysql_ip" {
  value = aws_instance.db.public_ip
}