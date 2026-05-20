# 📦 App de Despachos y Ventas

Sistema de gestión integral que permite a las empresas administrar de forma separada y escalable sus operaciones de despacho y ventas. Cuenta con una interfaz web moderna y despliegue automatizado en la nube de AWS.

---

## 🌟 Descripción General

Este proyecto es un sistema basado en microservicios. Consta de una interfaz web (Frontend) y dos servicios de respaldo (Backends) totalmente independientes. Todo el sistema funciona dentro de contenedores, está alojado en la nube de AWS y se construye utilizando **Infraestructura como Código (Terraform)**, lo que permite crearlo y destruirlo de forma rápida y segura.

## 📑 Tabla de Contenidos

1. [Descripción General](#-descripción-general)
2. [Arquitectura del Sistema](#-arquitectura-del-sistema)
3. [Microservicios](#-microservicios)
4. [Stack Tecnológico](#-stack-tecnológico)
5. [Patrones y Estándares](#-patrones-y-estándares)
6. [Transacciones Distribuidas](#-transacciones-distribuidas)
7. [Manejo de Errores](#-manejo-de-errores)
8. [Infraestructura](#-infraestructura)
9. [Estructura del Proyecto](#-estructura-del-proyecto)
10. [Configuración del Entorno](#-configuración-del-entorno)
11. [Ejecución Local](#-ejecución-local)
12. [CI/CD y Observabilidad](#-cicd-y-observabilidad)
13. [Pruebas](#-pruebas)
14. [Frontend Detallado](#-frontend-detallado)
15. [Roadmap](#-roadmap)
16. [Contribución](#-contribución)

---
## 🏗️ Arquitectura del Sistema
```text
┌─────────────────────────────────────────────────────────────────┐
│                         AWS Cloud                               │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    VPC (10.0.0.0/16)                     │   │
│  │  ┌────────────────────────────────────────────────────┐  │   │
│  │  │              Public Subnet (10.0.1.0/24)           │  │   │
│  │  │  ┌──────────────────────────────────────────────┐  │  │   │
│  │  │  │            ECS Fargate Cluster               │  │  │   │
│  │  │  │  ┌────────────────────────────────────────┐  │  │  │   │
│  │  │  │  │  Task: <nombre_proyecto>-app           │  │  │  │   │
│  │  │  │  │  ├── frontend (Nginx, puerto 80)       │  │  │  │   │
│  │  │  │  │  ├── backend-despachos (puerto 8080)   │  │  │  │   │
│  │  │  │  │  └── backend-ventas (puerto 8081)      │  │  │  │   │
│  │  │  │  └────────────────────────────────────────┘  │  │  │   │
│  │  │  └──────────────────────────────────────────────┘  │  │   │
│  │  │                                                     │  │   │
│  │  │  ┌──────────────────────────────────────────────┐  │  │   │
│  │  │  │    EC2 Instance (MySQL 8.0)                  │  │  │   │
│  │  │  │    - Docker container con MySQL              │  │  │   │
│  │  │  │    - Puerto 3306 expuesto internamente       │  │  │   │
│  │  │  └──────────────────────────────────────────────┘  │  │   │
│  │  └────────────────────────────────────────────────────┘  │   │
│  │                                                           │   │
│  │  ┌────────────────────────────────────────────────────┐  │   │
│  │  │              ECR Repositories                      │  │   │
│  │  │  - <nombre_proyecto>-backend-despachos             │  │   │
│  │  │  - <nombre_proyecto>-backend-ventas                │  │   │
│  │  │  - <nombre_proyecto>-frontend                      │  │   │
│  │  └────────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘



## 📡 Flujo de Comunicación
* **Usuario** → Frontend (React) alojado en Nginx.
* **Frontend** → Backend APIs mediante HTTP (puertos 8080 y 8081).
* **Backends** → MySQL en EC2 (puerto 3306) para persistencia.
* **Logs** → Envío a CloudWatch Logs para monitoreo centralizado.

---

## 🧩 Microservicios

### 1. Backend Despachos (`despacho-service`)
* **Puerto:** 8080
* **Responsabilidad:** Gestión de despachos, seguimiento de envíos, logística.
* **Documentación API:** Swagger UI disponible en `/swagger-ui.html`.

### 2. Backend Ventas (`venta-service`)
* **Puerto:** 8081
* **Responsabilidad:** Gestión de ventas, facturación, clientes.
* **Documentación API:** Swagger UI disponible en `/swagger-ui.html`.

### 3. Frontend (`frontend`)
* **Tecnología:** React 18 + Vite + TailwindCSS.
* **Servidor:** Nginx (servidor web ligero y rápido).
* **Routing / Estado:** React Router DOM v6 / React Hooks.

---

## 💻 Stack Tecnológico

| Capa | Tecnologías |
| :--- | :--- |
| **Frontend** | React 18, Vite 5, TailwindCSS 3, pnpm, Nginx |
| **Backend** | Java 21, Spring Boot 3.x, Spring Data JPA, Maven |
| **Base de Datos** | MySQL 8.0 (Oracle) en contenedor Docker |
| **Infraestructura** | AWS (VPC, ECS Fargate, ECR, EC2, CloudWatch), Terraform |
| **CI/CD** | GitHub Actions, Docker Build, ECS Deployment |
| **Health Checks** | Spring Boot Actuator, Swagger UI, netcat (nc) |
| **Documentación** | SpringDoc OpenAPI (Swagger) |

### Dependencias Principales

**Frontend (`package.json`):**
```json
{
  "react": "^18.2.0",
  "react-dom": "^18.2.0",
  "react-router-dom": "^6.24.1",
  "react-hook-form": "^7.52.1",
  "react-icons": "^5.1.0",
  "axios": "^1.6.8",
  "sweetalert2": "^11.11.0"
}
```

**Backend (Spring Boot Starters):**
`web`, `data-jpa`, `actuator`, `mysql-connector-java`, `springdoc-openapi-starter-webmvc-ui`.

---

## 📐 Patrones y Estándares

### Patrones de Diseño:
* **API Gateway implícito:** El frontend consume directamente los dos microservicios.
* **Database per Service:** Cada microservicio tiene su propia base de datos (actualmente comparten instancia MySQL pero están aislados por esquema lógico).
* **Service Discovery:** No implementado (comunicación directa por IP).
* **Configuración externalizada:** Variables de entorno para credenciales y conexiones.

### Estándares de Código:
* **Frontend:** ESLint + Prettier.
* **Backend:** Estándar Java 21, convenciones Spring Boot.

---

## 🔄 Transacciones Distribuidas

* **Estado actual:** No se implementan transacciones distribuidas entre microservicios. Cada servicio gestiona sus propias transacciones locales.
* **Propuesta de implementación futura (SAGA Pattern):** Para operaciones que cruzan ambos servicios (ej. crear venta y agendar despacho), se sugiere implementar:
  * Coreografía de eventos con RabbitMQ (ya contemplado en futura infraestructura).
  * Orquestación con temporal.io o AWS Step Functions.
* **Estrategia actual para consistencia:**
  * **Eventual consistency:** Si falla una operación secundaria, se registra en logs y se alerta.
  * **Circuit Breaker:** Planificado usando Resilience4j en futuras iteraciones.

---

## 🛡️ Manejo de Errores

### Estrategias Implementadas

| Componente | Mecanismo | Descripción |
| :--- | :--- | :--- |
| **Backend** | `spring.sql.init.continue-on-error=true` | No falla si hay errores en scripts SQL iniciales |
| **Backend** | `hikari.initializationFailTimeout=-1` | Espera indefinidamente a que MySQL esté disponible |
| **Backend** | Health checks `/swagger-ui.html` | ECS monitorea la salud del servicio continuamente |
| **Backend** | Entrypoint con `nc -z $DB_HOST 3306` | Espera activa a MySQL antes de iniciar Spring Boot |
| **Frontend** | `HEALTHCHECK` en Nginx | ECS sabe si el frontend está vivo |
| **Frontend** | `dependsOn` (ECS) | El frontend espera a que los backends inicien |

> **Nota sobre fallos específicos:** Si MySQL no está disponible al inicio, Spring Boot espera, los health checks fallan y ECS reiniciará el contenedor (hasta 5 reintentos) hasta que MySQL termine de arrancar (EC2 tarda ~2 mins).

---

## ☁️ Infraestructura (Terraform)

La infraestructura está dividida en módulos `.tf` para fácil mantenimiento:

| Recurso | Propósito |
| :--- | :--- |
| **VPC & Subnets** | Red aislada (10.0.0.0/16), Subred Pública (10.0.1.0/24) |
| **Internet Gateway & Rutas** | Salida a internet (0.0.0.0/0) |
| **Security Group** | Puertos 22, 80, 8080, 8081, 3306 abiertos internamente |
| **EC2 MySQL** | Instancia t3.micro, 30GB gp3, user_data con Docker |
| **ECR Repositories** | 3 repositorios para almacenar imágenes Docker |
| **ECS Cluster & Task** | Fargate modo awsvpc, CPU 1024, RAM 2048 |
| **CloudWatch Logs** | Grupo /ecs/<nombre_proyecto> con retención de 7 días |
| **IAM Role** | LabRole (proporcionado por AWS Academy) |

---

## 📂 Estructura del Proyecto

```plaintext
despacho-project/
├── .github/workflows/
│   └── cd.yml                    # Pipeline CI/CD de GitHub Actions
├── backend/
│   ├── despacho-service/
│   │   ├── Dockerfile            # Multi-stage, netcat health check
│   │   ├── pom.xml               
│   │   └── src/main/resources/application.properties
│   └── venta-service/
│       ├── Dockerfile            
│       └── pom.xml
├── frontend/
│   ├── Dockerfile                # Node 22 + pnpm + Nginx
│   ├── nginx.conf                # Configuración SPA + caching
│   ├── package.json
│   ├── vite.config.js
│   ├── tailwind.config.js
│   └── src/
└── infrastructure/
    ├── providers.tf              # AWS Provider
    ├── vpc.tf                    # VPC, Subnets, IGW, Route Tables
    ├── security_groups.tf        # SGs para ECS y EC2
    ├── ecr.tf                    # Repositorios Docker
    ├── instances.tf              # Servidor EC2 de Base de Datos
    ├── ecs.tf                    # Cluster, Task Def, Service
    ├── variables.tf              # Declaración de variables
    └── terraform.tfvars.example  # Plantilla de variables
```

---

## ⚙️ Configuración del Entorno

### Variables de Entorno (Inyectadas en ECS)
* `SPRING_DATASOURCE_URL`: Conexión JDBC (`jdbc:mysql://<DB_HOST>:3306/<nombre_base_datos>?...`)
* `SPRING_DATASOURCE_USERNAME`: root
* `SPRING_DATASOURCE_PASSWORD`: (secreto gestionado por Terraform)
* `DB_HOST`: IP privada de EC2 MySQL

### Archivo `terraform.tfvars` (Requerido Localmente)
```terraform
clave_ec2           = "vockey"
password_base_datos = "TuClaveSegura123"
nombre_base_datos   = "despachodb"
```

### Secrets en GitHub (Para CI/CD)
* `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` (Del lab Academy)
* `AWS_ACCOUNT_ID` (ID de tu cuenta de 12 dígitos)

---

## 🏃 Ejecución Local

**Requisitos previos:** Docker Desktop, Node.js 22 + pnpm, Java 17+ + Maven, MySQL local (opcional).

### Backends con Docker
```bash
# Construir imagen
docker build -t despacho-backend-test ./backend/despacho-service

# Ejecutar (requiere base de datos disponible)
docker run -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://host.docker.internal:3306/despachodb \
  -e SPRING_DATASOURCE_USERNAME=root \
  -e SPRING_DATASOURCE_PASSWORD=password \
  despacho-backend-test
```

### Frontend Local
```bash
cd frontend
pnpm install
pnpm dev   # Abre http://localhost:5173
```

---

## 🚀 CI/CD y Observabilidad

### Pipeline de GitHub Actions
* **Trigger:** Push a la rama main.
* **Jobs:** Checkout -> Configurar AWS Credentials -> Login ECR -> Build & Push de 3 imágenes -> Forzar nuevo despliegue ECS (update-service --force-new-deployment).
* **Duración típica:** 3-5 minutos.

### Comandos Útiles (AWS CLI)
```bash
# Ver logs de backend-despachos
aws logs get-log-events --log-group-name /ecs/<nombre_proyecto> --log-stream-name backend-despachos/xxxx

# Forzar despliegue manual
aws ecs update-service --cluster <nombre_proyecto>-cluster --service app --force-new-deployment
```

---

## 🧪 Pruebas

**Backend (Spring Boot):**
```bash
cd backend/despacho-service && mvn test
```

**Frontend:**
```bash
cd frontend && pnpm lint && pnpm build
```

**Pruebas de Integración (Post-Despliegue):**
```bash
curl http://<IP_PUBLICA>:8080/swagger-ui.html
curl http://<IP_PUBLICA>:8081/swagger-ui.html
```

---

## 🖥️ Frontend Detallado

### Servidor Nginx (Producción):
Configurado para soportar SPA (React Router) y Cache de assets estáticos:
```nginx
server {
    listen 80;
    root /usr/share/nginx/html;
    try_files $uri $uri/ /index.html;  # Soporte React Router

    # Cache de assets estáticos por 1 año
    location ~* \.(js|css|png|jpg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### Variables de Entorno (Vite): `.env.production`
```env
VITE_API_DESPACHOS_URL=http://<IP_PUBLICA>:8080
VITE_API_VENTAS_URL=http://<IP_PUBLICA>:8081
```

---

## 🗺️ Roadmap

### ✅ Implementado
* [x] Microservicios Spring Boot con JPA.
* [x] Frontend React con Vite y Tailwind.
* [x] Contenerización completa (Docker multi-stage).
* [x] Infraestructura AWS refactorizada y modularizada con Terraform.
* [x] CI/CD con GitHub Actions.
* [x] Health checks y logs centralizados.
```
