provider "aws" { 
  region = "us-east-1"
} 

# ==========================================
# RED (VPC, Subnets, Gateways)
# ==========================================
resource "aws_vpc" "vpc_innovatech_produccion" {
  cidr_block           = "10.0.0.0/16"          
  enable_dns_hostnames = true                    
  tags                 = { Name = "VPC-Innovatech-Chile" }
}

resource "aws_subnet" "subnet_publica_frontend" {
  vpc_id                  = aws_vpc.vpc_innovatech_produccion.id
  cidr_block              = "10.0.1.0/24"        
  map_public_ip_on_launch = true                 
  tags                    = { Name = "Subnet-Publica-Frontend" }
}

resource "aws_subnet" "subnet_privada_backend_data" {
  vpc_id     = aws_vpc.vpc_innovatech_produccion.id
  cidr_block = "10.0.2.0/24"                      
  tags       = { Name = "Subnet-Privada-App" }
}         

resource "aws_internet_gateway" "igw_innovatech" {
  vpc_id = aws_vpc.vpc_innovatech_produccion.id
  tags   = { Name = "IGW-Innovatech" }
}  

resource "aws_eip" "eip_nat" {
  domain     = "vpc"   
  depends_on = [aws_internet_gateway.igw_innovatech]
}                         

resource "aws_nat_gateway" "nat_gateway_privado" {
  allocation_id = aws_eip.eip_nat.id              
  subnet_id     = aws_subnet.subnet_publica_frontend.id
  tags          = { Name = "NAT-Innovatech" }
  depends_on    = [aws_internet_gateway.igw_innovatech]
}  

# ==========================================
# TABLAS DE ENRUTAMIENTO 
# ==========================================
resource "aws_route_table" "rt_publica" {
  vpc_id = aws_vpc.vpc_innovatech_produccion.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_innovatech.id
  }
  tags = { Name = "RT-Publica-Innovatech" }
}

resource "aws_route_table_association" "rta_publica_frontend" {
  subnet_id      = aws_subnet.subnet_publica_frontend.id
  route_table_id = aws_route_table.rt_publica.id
}

resource "aws_route_table" "rt_privada" {
  vpc_id = aws_vpc.vpc_innovatech_produccion.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_privado.id
  }
  tags = { Name = "RT-Privada-Innovatech" }
}

resource "aws_route_table_association" "rta_privada_backend" {
  subnet_id      = aws_subnet.subnet_privada_backend_data.id
  route_table_id = aws_route_table.rt_privada.id
}

# ==========================================
# SECURITY GROUPS
# ==========================================
resource "aws_security_group" "sg_capa_frontend" {
  name   = "SG-Frontend-Innovatech"
  vpc_id = aws_vpc.vpc_innovatech_produccion.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_capa_backend" {
  name   = "SG-Backend-Innovatech"
  vpc_id = aws_vpc.vpc_innovatech_produccion.id
  
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_capa_frontend.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_capa_datos" {
  name   = "SG-Datos-Innovatech"
  vpc_id = aws_vpc.vpc_innovatech_produccion.id

  ingress {
    from_port       = 3306 
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_capa_backend.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==========================================
# CÓMPUTO (Launch Templates & EC2)
# ==========================================
resource "aws_launch_template" "template_instancias_devops" {
  name_prefix   = "Innovatech-Standard-"
  image_id      = "ami-0c7217cdde317cfec" 
  instance_type = "t2.micro"
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y                             
    apt-get install -y git docker.io              
    systemctl start docker                        
    systemctl enable docker                       
  EOF
  )
}

resource "aws_instance" "ec2_frontend" {
  launch_template { id = aws_launch_template.template_instancias_devops.id }
  subnet_id              = aws_subnet.subnet_publica_frontend.id 
  vpc_security_group_ids = [aws_security_group.sg_capa_frontend.id]
  tags                   = { Name = "EC2-Frontend-Innovatech" }
}

resource "aws_instance" "ec2_backend" {
  launch_template { id = aws_launch_template.template_instancias_devops.id }
  subnet_id              = aws_subnet.subnet_privada_backend_data.id 
  vpc_security_group_ids = [aws_security_group.sg_capa_backend.id]
  tags                   = { Name = "EC2-Backend-Innovatech" }
}

resource "aws_instance" "ec2_datos" {
  launch_template { id = aws_launch_template.template_instancias_devops.id }
  subnet_id              = aws_subnet.subnet_privada_backend_data.id 
  vpc_security_group_ids = [aws_security_group.sg_capa_datos.id]
  tags                   = { Name = "EC2-Datos-Innovatech" }
}

# ==========================================
# REPOSITORIOS ECR (Imágenes Docker)
# ==========================================
resource "aws_ecr_repository" "frontend" {
  name                 = "frontend-innovatech"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "backend" {
  name                 = "backend-innovatech"
  image_tag_mutability = "MUTABLE"
}