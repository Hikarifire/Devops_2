# 📦 App de Despachos y Ventas

Sistema de gestión integral que permite a las empresas administrar de forma separada y escalable sus operaciones de despacho y ventas. Cuenta con una interfaz web moderna y despliegue automatizado en la nube de AWS.

---

## 🌟 Descripción General

Este proyecto es un sistema basado en microservicios. Consta de una interfaz web (Frontend) y dos servicios de respaldo (Backends) totalmente independientes. Todo el sistema funciona dentro de contenedores, está alojado en la nube de AWS y se construye utilizando **Infraestructura como Código (Terraform)**, lo que permite crearlo y destruirlo de forma rápida y segura.

---

## 🏗️ Arquitectura del Sistema
El sistema consta de:
1. **Frontend (React):** Interfaz web alojada en Nginx.
2. **Backend Despachos (Spring Boot):** API para logística y envíos.
3. **Backend Ventas (Spring Boot):** API para facturación y clientes.
4. **Base de Datos:** MySQL 8.0 alojada en AWS EC2.

El código se despliega automáticamente en **AWS ECS Fargate** mediante GitHub Actions.

## 📂 Estructura del Repositorio
Para conocer los detalles de cada componente, visita su documentación específica:

* 🌐 [**Frontend**](./frontend/README.md): Código fuente de la interfaz web (React + Vite).
* ⚙️ [**Backends**](./backend/README.md): Microservicios de ventas y despachos (Java Spring Boot).
* ☁️ [**Infraestructura**](./infrastructure/README.md): Código de Terraform para levantar todo en AWS.
* 🔄 **`.github/workflows`**: Pipeline de CI/CD automatizado.

## 🚀 CI/CD y Observabilidad
El proyecto utiliza **GitHub Actions**. Al integrar código en la rama `main`, el pipeline automáticamente:
1. Construye las imágenes Docker.
2. Las sube a AWS ECR.
3. Actualiza los servicios en ECS Fargate sin tiempo de inactividad.

Los logs centralizados se pueden visualizar en **AWS CloudWatch**.

## 🤝 Contribución
Crea una rama desde `develop`, realiza tus commits siguiendo la convención (`feat:`, `fix:`, `infra:`) y abre un Pull Request.
2. Archivo de Infraestructura: infrastructure/README.md
(Guárdalo dentro de la carpeta infrastructure)

Markdown
# ☁️ Infraestructura como Código (Terraform)

Esta carpeta contiene todos los archivos `.tf` necesarios para desplegar la red, los servidores, los contenedores y las bases de datos en **AWS**.

## 📁 Archivos Principales
* `vpc.tf`: Configuración de la red aislada (Subnets, Gateway).
* `security_groups.tf`: Reglas de firewall (Puertos 80, 8080, 8081, 3306).
* `ecs.tf`: Clúster de contenedores Fargate para los microservicios.
* `instances.tf`: Servidor EC2 ejecutando MySQL.
* `ecr.tf`: Repositorios para imágenes Docker.

## 🚀 Guía de Despliegue Local

1. **Requisitos Previos:**
   Tener instalado [Terraform](https://developer.hashicorp.com/terraform/downloads) y credenciales de AWS activas en tu terminal.

2. **Configurar Variables:**
   Copia el archivo de ejemplo y configúralo con tus datos:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
Edita terraform.tfvars con tu clave_ec2, el nombre y el password de la base de datos.

Ejecutar Despliegue:

Bash
terraform init
terraform validate
terraform plan
terraform apply
⚠️ Aviso para AWS Academy: Usa End Lab para pausar los recursos. No uses Reset para no perder el estado de Terraform.


---

### 3. Archivo del Backend: `backend/README.md`
*(Guárdalo dentro de la carpeta `backend`)*

```markdown
# ⚙️ Microservicios Backend

Este directorio contiene los microservicios desarrollados en **Java 21** con **Spring Boot 3**. 

## 🧩 Servicios Disponibles

1. **`despacho-service` (Puerto 8080)**: Gestiona la logística y el estado de los envíos.
2. **`venta-service` (Puerto 8081)**: Gestiona la facturación y la información de clientes.

Ambos servicios utilizan una arquitectura *Database per Service* a nivel lógico (esquemas separados) y exponen su documentación API mediante **Swagger** en `/swagger-ui.html`.

## 🛡️ Tolerancia a Fallos
Implementan estrategias de resiliencia:
* Espera activa a MySQL mediante un script `netcat` (`nc`) en el `Dockerfile`.
* Timeout infinito de inicio en HikariCP para esperar a que la base de datos esté lista tras un reinicio de infraestructura.

## 🏃 Ejecución Local con Docker

Para probar un microservicio en tu máquina local:

```bash
# 1. Construir la imagen
docker build -t despacho-backend-test ./despacho-service

# 2. Ejecutar (Asegúrate de tener MySQL corriendo o ajustar las variables)
docker run -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://host.docker.internal:3306/despachodb \
  -e SPRING_DATASOURCE_USERNAME=root \
  -e SPRING_DATASOURCE_PASSWORD=tu_password \
  despacho-backend-test

---

### 4. Archivo del Frontend: `frontend/README.md`
*(Guárdalo dentro de la carpeta `frontend`)*

```markdown
# 🌐 Frontend Web

Aplicación Single Page Application (SPA) construida con **React 18**, **Vite** y **TailwindCSS**.

## 🛠️ Stack Tecnológico
* **React Router DOM v6** para navegación.
* **Axios** para peticiones HTTP a los microservicios.
* **React Hook Form** para manejo de formularios.
* Empaquetado en un contenedor Docker ultraligero usando **Nginx**.

## ⚙️ Variables de Entorno
Crea un archivo `.env.production` (o `.env.local` para pruebas) con las URLs de los microservicios:
```env
VITE_API_DESPACHOS_URL=http://<IP_PUBLICA>:8080
VITE_API_VENTAS_URL=http://<IP_PUBLICA>:8081
🏃 Ejecución Local
Para levantar el entorno de desarrollo:

Bash
# 1. Instalar dependencias usando pnpm
pnpm install

# 2. Levantar servidor local (Abre en localhost:5173)
pnpm dev

# 3. Compilar para producción (Opcional)
pnpm build
🐳 Despliegue en Producción
El Dockerfile utiliza un proceso multi-stage (Node.js para construir, Nginx para servir). Nginx está configurado para manejar correctamente las rutas de React y cachear los archivos estáticos.


---

### 💡 ¿Cómo subir esto a GitHub?
Una vez que hayas guardado cada archivo `README.md` en su respectiva carpeta, ejecuta estos comandos en tu terminal en la raíz del proyecto:

```bash
git add .
git commit -m "docs: modularizar la documentacion del proyecto con READMEs especificos"
git push origin tu-rama
Con esta estructura, cuando alguien entre a la carpeta infrastructure en GitHub, verá automáticamente la documentación de Terraform, y cuando entre a frontend, verá cómo usar React. ¡Quedará nivel experto!
