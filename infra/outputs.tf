output "backend_despacho_ecr" {
  value       = aws_ecr_repository.backend_despacho.repository_url
  description = "URL del ECR de Despachos"
}

output "backend_ventas_ecr" {
  value       = aws_ecr_repository.backend_ventas.repository_url
  description = "URL del ECR de Ventas"
}
output "frontend_ecr" {
  value = aws_ecr_repository.frontend.repository_url
}
output "mysql_ip" {
  value = aws_instance.db.public_ip
}