# Retail Store — Microservices Deployment on AWS EKS

A production-grade microservices deployment on **Amazon EKS** using a full GitOps stack: **Terraform**, **ArgoCD**, **Helm**, and **GitHub Actions**. The application is a retail store sample with five independent services, deployed and managed entirely through code.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Cloud | AWS (EKS, ECR, VPC, NLB) |
| Infrastructure as Code | Terraform |
| Container Orchestration | Kubernetes (EKS) |
| GitOps | ArgoCD |
| Package Manager | Helm |
| CI/CD | GitHub Actions |
| Ingress | NGINX Ingress Controller |
| Monitoring | Prometheus + Grafana |

---

## Architecture

```
![alt text](EKS.gif)

---

## Services

| Service | Language | Description |
|---|---|---|
| UI | Java (Spring Boot) | Store frontend |
| Catalog | Go | Product catalog API |
| Cart | Java (Spring Boot) | Shopping cart API |
| Orders | Java (Spring Boot) | Order management API |
| Checkout | Node.js (NestJS) | Checkout orchestration API |

---


## Branch Strategy

| Branch | Purpose |
|---|---|
| `main` | Helm charts with public ECR images — stable, manual deployment |
| `gitops` | CI/CD branch — GitHub Actions builds images, pushes to ECR, updates Helm values, ArgoCD syncs automatically |

---

## Key Concepts Demonstrated

- **GitOps** — Git as the single source of truth for both infrastructure and application state
- **Helm umbrella charts** — managing multi-service deployments with subchart dependencies and `fullnameOverride` for DNS control
- **ArgoCD AppProject** — RBAC and resource whitelisting for namespace-scoped deployments
- **Multi-stage Docker builds** — optimized images for Java, Go, and Node.js services
- **IaC with Terraform** — EKS cluster, VPC, and addon management via `eks-blueprints-addons`
- **Observability** — Prometheus scraping pod metrics, Grafana dashboards for cluster and node visibility