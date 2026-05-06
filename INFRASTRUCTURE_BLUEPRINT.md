# DevOps Fintech Infrastructure & Deployment Blueprint

## Overview
This blueprint defines a secure, highly available, cost-optimized AWS deployment for a containerized React + Node.js fintech-style application using Terraform, Docker, EKS, GitHub Actions, and Argo CD.

The current repository is a task manager application with a React frontend and Node.js backend. This design upgrades the deployment architecture to support a production-grade AWS microservices stack with PostgreSQL and Redis.

---

## a) Architecture Design

### 1. High-Level AWS Architecture

- Primary Region: `ap-south-1` (Mumbai)
- Secondary DR Region: `ap-southeast-1` (Singapore)
- Deployment Model: Active-Passive

Normal traffic is served from the Mumbai region. The Singapore region is a warm standby with synchronized data and a lower-cost compute footprint.

### 2. VPC Design

Each region contains a dedicated VPC with the following CIDRs:

- Primary VPC: `10.0.0.0/16`
- Secondary VPC: `10.1.0.0/16`

Subnet layout across 3 AZs per region:

- Public subnets: ALB, NAT Gateway
- Private app subnets: EKS worker nodes
- Private data subnets: RDS PostgreSQL / Redis

Example AZ design for `ap-south-1`:

| AZ | Public | Private App | Private DB |
| --- | --- | --- | --- |
| ap-south-1a | 10.0.1.0/24 | 10.0.11.0/24 | 10.0.21.0/24 |
| ap-south-1b | 10.0.2.0/24 | 10.0.12.0/24 | 10.0.22.0/24 |
| ap-south-1c | 10.0.3.0/24 | 10.0.13.0/24 | 10.0.23.0/24 |

### 3. Component Placement

- Public Layer: ALB, Route53, WAF, NAT Gateways
- Private App Layer: EKS cluster, managed node groups, frontend/backend pods, Argo CD, monitoring
- Private Data Layer: Amazon RDS PostgreSQL, Amazon ElastiCache Redis

### 4. Kubernetes Networking

- Ingress: AWS Load Balancer Controller with ALB ingress
- Internal communication: ClusterIP services and Kubernetes DNS
- Secure communication: TLS termination at ALB, mTLS via service mesh, IRSA for pod IAM access

### 5. Multi-Region Deployment

- Primary region handles active production traffic
- Secondary region remains warm standby
- Cross-region read replica on RDS and Route53 failover records

### 6. Traffic Routing

- Route53 failover routing with health checks against ALB endpoints
- Primary region preferred; secondary region activated when primary health checks fail

### 7. High Availability

- EKS HA: multi-AZ node groups, multiple replicas, PodDisruptionBudgets, Cluster Autoscaler
- Database HA: RDS Multi-AZ and cross-region replica
- Redis HA: Redis replication group with automatic failover
- ALB across multiple AZs

### 8. Security Considerations

- Network: private subnets, least-privilege security groups, NACLs
- Secrets: AWS Secrets Manager with External Secrets Operator
- Containers: non-root users, minimal base images, signed scanned images
- IAM: IRSA, dedicated roles for workloads
- API protection: AWS WAF, rate limiting, HTTPS

### 9. Cost Optimization

- Managed EKS reduces ops overhead but increases cost
- Active-passive DR lowers cost compared to active-active
- Spot worker nodes for non-critical workloads
- Cluster Autoscaler reduces idle compute
- Redis caches reduce RDS load

---

## b) Terraform Strategy

### Repository Layout

```
terraform/
├── modules/
│   ├── vpc/
│   ├── eks/
│   ├── rds/
│   ├── redis/
│   ├── monitoring/
│   └── route53/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── global/
    └── iam/
```

### Modules

- `vpc`: VPC, public/private subnets, NAT gateways, route tables, IGW
- `eks`: EKS cluster, managed node groups, OIDC provider, IAM roles
- `rds`: PostgreSQL instance, Multi-AZ, read replica, parameter group
- `redis`: ElastiCache replication group, security group
- `monitoring`: CloudWatch, Prometheus/Grafana integration
- `route53`: DNS, failover records, health checks

### Remote State

Use S3 backend with DynamoDB locking:

```hcl
terraform {
  backend "s3" {
    bucket         = "fintech-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

### Environment Separation

Each environment has separate state, variables, and scale settings.

Example:

- `dev`: 1-2 nodes, `db.t3.micro`
- `staging`: 2-3 nodes, `db.t3.small`
- `prod`: 3-10 nodes, `db.r6g.large`

### Multi-Region Strategy

Use AWS provider aliases for primary and DR regions in Terraform.

### Dependency Management

Use module outputs and `depends_on` to ensure correct ordering.

---

## c) Docker & Image Strategy

### Backend Dockerfile
- Multi-stage build
- Node 20 alpine builder
- Production dependencies only
- Non-root user

### Frontend Dockerfile
- Build React app in Node
- Serve static files from lightweight web server or NGINX

### Registry
- Amazon ECR with tagged images:
  - `frontend:${GITHUB_SHA}`
  - `backend:${GITHUB_SHA}`
  - `backend:latest`

### Security
- Minimal base images
- Non-root users
- Image scanning with Trivy/Grype
- Auto-clean old untagged images

---

## d) Kubernetes Deployment

### Namespaces

- `frontend`
- `backend`
- `monitoring`
- `argocd`

### Deployment Strategy

- RollingUpdate with `maxUnavailable: 0` and `maxSurge: 1`
- Readiness and liveness probes on each service
- Horizontal Pod Autoscaler for stateless workloads
- Cluster Autoscaler for node scaling

### Secrets

- Use AWS Secrets Manager and External Secrets Operator
- Avoid hardcoded secrets

### Communication

- Internal service discovery via Kubernetes DNS
- `backend-service.backend.svc.cluster.local`
- Optional service mesh for mTLS

### GitOps

- Argo CD watches the Git repo
- Changes in manifests trigger automatic sync
- Rollback by reverting Git commit

---

## e) CI/CD Pipeline Design

### GitHub Actions Stages

- Source: push to `main`, PRs, release tags
- Build: install dependencies, run tests, lint, build Docker images
- Security: dependency audit, Trivy scan, ESLint
- Push: authenticate to ECR and push images
- Manifest Update: update image tags in GitOps manifests
- Deployment: Argo CD sync or manual promotion

### Failure Handling

- Kubernetes rollbacks on failed rollout
- Argo CD reverts to stable state if sync fails
- Health checks block promotion

---

## f) Failure & Failover

### Route53 Failover

- Primary ALB health checks
- Automatic DNS failover to DR region
- Secondary EKS cluster becomes active when needed

### Data Consistency

- Primary RDS is read/write
- Secondary region uses cross-region read replica
- Promote replica on failover

### Redis

- Use ElastiCache replication with automatic failover
- Consider Redis Global Datastore for cross-region replication

---

## Recommended Next Steps

1. Create the Terraform modules in `terraform/modules/`
2. Add environment-specific root configs in `terraform/environments/`
3. Build Docker images with the `docker/` files
4. Add GitHub Actions workflow in `.github/workflows/`
5. Add Argo CD GitOps manifests in `k8s/`
6. Gradually switch backend from MongoDB to PostgreSQL and Redis for production resilience
