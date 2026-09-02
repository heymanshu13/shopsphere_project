# ShopSphere

Production-grade microservices DevOps project.

## Microservices

- User Service
- Product Service
- Order Service
- Payment Service
- Notification Service

## DevOps Stack

- Git
- Jenkins
- Docker
- Terraform
- AWS
- Kubernetes
- Argo CD
- SonarQube
- Trivy

## Architecture

Client
    |
    v
Order Service
    |
    +--> User Service
    |
    +--> Product Service
    |
    +--> Payment Service
    |
    +--> Notification Service

## Local Ports

| Service | Port |
|---|---:|
| User | 8001 |
| Product | 8002 |
| Order | 8003 |
| Payment | 8004 |
| Notification | 8005 |
