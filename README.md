# 📦 App de Despachos y Ventas

Sistema de gestión integral que permite a las empresas administrar de forma separada y escalable sus operaciones de despacho y ventas. Cuenta con una interfaz web moderna y despliegue automatizado en la nube de AWS.

---

## 🌟 Descripción General

Este proyecto es un sistema basado en microservicios. Consta de una interfaz web (Frontend) y dos servicios de respaldo (Backends) totalmente independientes. Todo el sistema funciona dentro de contenedores, está alojado en la nube de AWS y se construye utilizando **Infraestructura como Código (Terraform)**, lo que permite crearlo y destruirlo de forma rápida y segura.

---

## 🏗️ Arquitectura del Sistema

El sistema funciona en la nube de AWS y se divide en las siguientes partes:

1. **Frontend (React):** La interfaz visual donde interactúan los usuarios.
2. **Backend Despachos:** Se encarga de la logística y el seguimiento de envíos.
3. **Backend Ventas:** Administra la facturación y los clientes.
4. **Base de Datos (MySQL):** Almacena toda la información del sistema.

**Flujo de Comunicación:**
* El usuario interactúa con la web (Frontend).
* La web se comunica de forma transparente con las APIs de los Backends.
* Los Backends procesan la lógica y persisten la información en la Base de Datos.

---

## 💻 Stack Tecnológico

| Capa | Tecnologías |
| :--- | :--- |
| **Frontend** | React 18, Vite, TailwindCSS |
| **Backend** | Java 21, Spring Boot 3.x |
| **Base de Datos** | MySQL 8.0 |
| **Infraestructura** | AWS (ECS Fargate, ECR, EC2, VPC) |
| **Automatización** | Terraform, GitHub Actions, Docker |

---

## 📁 Estructura del Proyecto

El monorepo está organizado de la siguiente manera:

```text
despacho-project/
├── .github/workflows/        # Pipelines de CI/CD para GitHub Actions
├── backend/
│   ├── despacho-service/     # Microservicio de despachos (Spring Boot)
│   └── venta-service/        # Microservicio de ventas (Spring Boot)
├── frontend/                 # Aplicación SPA (React)
└── infrastructure/           # Infraestructura como Código
    ├── providers.tf          # Configuración de AWS
    ├── vpc.tf                # Redes y subredes
    ├── security_groups.tf    # Reglas de firewall
    ├── ecr.tf                # Repositorios de contenedores
    ├── instances.tf          # Servidor de Base de Datos
    ├── ecs.tf                # Clúster de microservicios
    ├── variables.tf          # Declaración de variables
    └── terraform.tfvars.example
