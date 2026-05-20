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

## 🌟 Descripción General

Este proyecto es un sistema de gestión integral que combina un frontend en React con dos microservicios Spring Boot independientes para gestionar operaciones de despachos y ventas. El sistema está completamente contenerizado y desplegado en AWS Fargate utilizando infraestructura como código con **Terraform** y un pipeline de CI/CD automatizado con **GitHub Actions**.

**Problema que resuelve:** Permite a las empresas gestionar de forma separada y escalable las operaciones de despacho y ventas, con una interfaz de usuario moderna y despliegue automatizado en la nube.

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
Flujo de Comunicación:Usuario → Frontend (React) alojado en Nginx.Frontend → Backend APIs mediante HTTP (puertos 8080 y 8081).Backends → MySQL en EC2 (puerto 3306) para persistencia.Logs → Envío a CloudWatch Logs para monitoreo centralizado.🧩 Microservicios1. Backend Despachos (despacho-service)Puerto: 8080Responsabilidad: Gestión de despachos, seguimiento de envíos, logística.Documentación API: Swagger UI disponible en /swagger-ui.html.2. Backend Ventas (venta-service)Puerto: 8081Responsabilidad: Gestión de ventas, facturación, clientes.Documentación API: Swagger UI disponible en /swagger-ui.html.3. Frontend (frontend)Tecnología: React 18 + Vite + TailwindCSS.Servidor: Nginx (servidor web ligero y rápido).Routing / Estado: React Router DOM v6 / React Hooks.💻 Stack TecnológicoCapaTecnologíasFrontendReact 18, Vite 5, TailwindCSS 3, pnpm, NginxBackendJava 21, Spring Boot 3.x, Spring Data JPA, MavenBase de DatosMySQL 8.0 (Oracle) en contenedor DockerInfraestructuraAWS (VPC, ECS Fargate, ECR, EC2, CloudWatch), TerraformCI/CDGitHub Actions, Docker Build, ECS DeploymentHealth ChecksSpring Boot Actuator, Swagger UI, netcat (nc)DocumentaciónSpringDoc OpenAPI (Swagger)Dependencias PrincipalesFrontend (package.json):JSON{
  "react": "^18.2.0",
  "react-dom": "^18.2.0",
  "react-router-dom": "^6.24.1",
  "react-hook-form": "^7.52.1",
  "react-icons": "^5.1.0",
  "axios": "^1.6.8",
  "sweetalert2": "^11.11.0"
}
Backend (Spring Boot Starters):web, data-jpa, actuator, mysql-connector-java, springdoc-openapi-starter-webmvc-ui.📐 Patrones y EstándaresPatrones de Diseño:API Gateway implícito: El frontend consume directamente los dos microservicios.Database per Service: Cada microservicio tiene su propia base de datos (actualmente comparten instancia MySQL pero están aislados por esquema lógico).Service Discovery: No implementado (comunicación directa por IP).Configuración externalizada: Variables de entorno para credenciales y conexiones.Estándares de Código:Frontend: ESLint + Prettier.Backend: Estándar Java 21, convenciones Spring Boot.🔄 Transacciones DistribuidasEstado actual: No se implementan transacciones distribuidas entre microservicios. Cada servicio gestiona sus propias transacciones locales.Propuesta de implementación futura (SAGA Pattern):Para operaciones que cruzan ambos servicios (ej. crear venta y agendar despacho), se sugiere implementar:Coreografía de eventos con RabbitMQ (ya contemplado en futura infraestructura).Orquestación con temporal.io o AWS Step Functions.Estrategia actual para consistencia:Eventual consistency: Si falla una operación secundaria, se registra en logs y se alerta.Circuit Breaker: Planificado usando Resilience4j en futuras iteraciones.🛡️ Manejo de ErroresEstrategias ImplementadasComponenteMecanismoDescripciónBackendspring.sql.init.continue-on-error=trueNo falla si hay errores en scripts SQL inicialesBackendhikari.initializationFailTimeout=-1Espera indefinidamente a que MySQL esté disponibleBackendHealth checks /swagger-ui.htmlECS monitorea la salud del servicio continuamenteBackendEntrypoint con nc -z $DB_HOST 3306Espera activa a MySQL antes de iniciar Spring BootFrontendHEALTHCHECK en NginxECS sabe si el frontend está vivoFrontenddependsOn (ECS)El frontend espera a que los backends inicienNota sobre fallos específicos: Si MySQL no está disponible al inicio, Spring Boot espera, los health checks fallan y ECS reiniciará el contenedor (hasta 5 reintentos) hasta que MySQL termine de arrancar (EC2 tarda ~2 mins).☁️ Infraestructura (Terraform)La infraestructura está dividida en módulos .tf para fácil mantenimiento:RecursoPropósitoVPC & SubnetsRed aislada (10.0.0.0/16), Subred Pública (10.0.1.0/24)Internet Gateway & RutasSalida a internet (0.0.0.0/0)Security GroupPuertos 22, 80, 8080, 8081, 3306 abiertos internamenteEC2 MySQLInstancia t3.micro, 30GB gp3, user_data con DockerECR Repositories3 repositorios para almacenar imágenes DockerECS Cluster & TaskFargate modo awsvpc, CPU 1024, RAM 2048CloudWatch LogsGrupo /ecs/<nombre_proyecto> con retención de 7 díasIAM RoleLabRole (proporcionado por AWS Academy)📂 Estructura del ProyectoPlaintextdespacho-project/
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
⚙️ Configuración del EntornoVariables de Entorno (Inyectadas en ECS)SPRING_DATASOURCE_URL: Conexión JDBC (jdbc:mysql://<DB_HOST>:3306/<nombre_base_datos>?...)SPRING_DATASOURCE_USERNAME: rootSPRING_DATASOURCE_PASSWORD: (secreto gestionado por Terraform)DB_HOST: IP privada de EC2 MySQLArchivo terraform.tfvars (Requerido Localmente)Terraformclave_ec2           = "vockey"
password_base_datos = "TuClaveSegura123"
nombre_base_datos   = "despachodb"
Secrets en GitHub (Para CI/CD)AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN (Del lab Academy)AWS_ACCOUNT_ID (ID de tu cuenta de 12 dígitos)🏃 Ejecución LocalRequisitos previos: Docker Desktop, Node.js 22 + pnpm, Java 17+ + Maven, MySQL local (opcional).Backends con DockerBash# Construir imagen
docker build -t despacho-backend-test ./backend/despacho-service

# Ejecutar (requiere base de datos disponible)
docker run -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://host.docker.internal:3306/despachodb \
  -e SPRING_DATASOURCE_USERNAME=root \
  -e SPRING_DATASOURCE_PASSWORD=password \
  despacho-backend-test
Frontend LocalBashcd frontend
pnpm install
pnpm dev   # Abre http://localhost:5173
🚀 CI/CD y ObservabilidadPipeline de GitHub ActionsTrigger: Push a la rama main.Jobs: Checkout -> Configurar AWS Credentials -> Login ECR -> Build & Push de 3 imágenes -> Forzar nuevo despliegue ECS (update-service --force-new-deployment).Duración típica: 3-5 minutos.Comandos Útiles (AWS CLI)Bash# Ver logs de backend-despachos
aws logs get-log-events --log-group-name /ecs/<nombre_proyecto> --log-stream-name backend-despachos/xxxx

# Forzar despliegue manual
aws ecs update-service --cluster <nombre_proyecto>-cluster --service app --force-new-deployment
🧪 PruebasBackend (Spring Boot): cd backend/despacho-service && mvn testFrontend: cd frontend && pnpm lint && pnpm buildPruebas de Integración (Post-Despliegue):Bashcurl http://<IP_PUBLICA>:8080/swagger-ui.html
curl http://<IP_PUBLICA>:8081/swagger-ui.html
🖥️ Frontend DetalladoServidor Nginx (Producción):Configurado para soportar SPA (React Router) y Cache de assets estáticos:Nginxserver {
    listen 80;
    root /usr/share/nginx/html;
    try_files $uri $uri/ /index.html;  # Soporte React Router

    # Cache de assets estáticos por 1 año
    location ~* \.(js|css|png|jpg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
Variables de Entorno (Vite): .env.productionFragmento de códigoVITE_API_DESPACHOS_URL=http://<IP_PUBLICA>:8080
VITE_API_VENTAS_URL=http://<IP_PUBLICA>:8081
🗺️ Roadmap✅ ImplementadoMicroservicios Spring Boot con JPA.Frontend React con Vite y Tailwind.Contenerización completa (Docker multi-stage).Infraestructura AWS refactorizada y modularizada con Terraform.CI/CD con GitHub Actions.Health checks y logs centralizados.
