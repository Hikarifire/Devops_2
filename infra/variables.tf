variable "aws_region" {
  default = "us-east-1"
}
variable "project_name" {
  default = "despacho-projecto"
}
variable "key_pair_name" {
  description = "Key Pair (debe existir en AWS)"
  type        = string
}
variable "db_password" {
  description = "Contraseña root MySQL"
  type        = string
  sensitive   = true
}
variable "db_name" {
  description = "Nombre base de datos"
  type        = string
  default     = "despachodb"
}