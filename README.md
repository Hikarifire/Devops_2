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

---

Flujo de Comunicación:

Usuario → Frontend (React) alojado en Nginx.

Frontend → Backend APIs mediante HTTP (puertos 8080 y 8081).

Backends → MySQL en EC2 (puerto 3306) para persistencia.

Logs → Envío a CloudWatch Logs para monitoreo centralizado.

---

🧩 Microservicios
1. Backend Despachos (despacho-service)
Puerto: 8080

Responsabilidad: Gestión de despachos, seguimiento de envíos, logística.

Documentación API: Swagger UI disponible en /swagger-ui.html.

2. Backend Ventas (venta-service)
Puerto: 8081

Responsabilidad: Gestión de ventas, facturación, clientes.

Documentación API: Swagger UI disponible en /swagger-ui.html.

3. Frontend (frontend)
Tecnología: React 18 + Vite + TailwindCSS.

Servidor: Nginx (servidor web ligero y rápido).

Routing / Estado: React Router DOM v6 / React Hooks.

---
