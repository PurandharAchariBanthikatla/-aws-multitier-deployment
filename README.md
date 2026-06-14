# AWS Multi-Tier Application Deployment

A 3-tier web application architecture (Web, Application, and Database layers) deployed on AWS using **Terraform**, demonstrating secure networking, least-privilege IAM, and Infrastructure as Code (IaC) practices.

---

## 📐 Architecture Overview

```
                                Internet
                                   |
                            [Internet Gateway]
                                   |
                        ┌──────────────────────┐
                        │   Custom VPC (10.0.0.0/16) │
                        └──────────────────────┘
                                   |
        ┌──────────────────────────────────────────────┐
        │                  Public Subnet (10.0.1.0/24)   │
        │   ┌─────────────┐        ┌──────────────────┐ │
        │   │  ALB / SG    │──────▶│  Web Tier (EC2)    │ │
        │   └─────────────┘        └──────────────────┘ │
        └──────────────────────────────────────────────┘
                                   |
        ┌──────────────────────────────────────────────┐
        │                 Private Subnet (10.0.2.0/24)   │
        │              ┌──────────────────────┐         │
        │              │ App Tier (EC2)        │         │
        │              └──────────────────────┘         │
        └──────────────────────────────────────────────┘
                                   |
        ┌──────────────────────────────────────────────┐
        │                 Private Subnet (10.0.3.0/24)   │
        │              ┌──────────────────────┐         │
        │              │ DB Tier (RDS/EC2)     │         │
        │              └──────────────────────┘         │
        └──────────────────────────────────────────────┘

        S3 Bucket (Static Assets) ── accessed via IAM Role from Web Tier
```

---

## 🎯 Project Goals

- Build a secure, scalable 3-tier architecture on AWS
- Practice subnetting, routing, and network isolation using a custom VPC
- Apply least-privilege access using IAM roles and security groups
- Automate provisioning end-to-end with Terraform (no manual console steps)
- Use S3 for static asset storage with controlled access

---

## 🛠️ Tech Stack

| Layer            | Technology                          |
|------------------|--------------------------------------|
| IaC              | Terraform                            |
| Compute          | Amazon EC2 (Web & App tiers)         |
| Database         | Amazon RDS (or EC2-hosted DB)        |
| Networking       | Custom VPC, Public/Private Subnets, IGW, NAT Gateway |
| Storage          | Amazon S3                            |
| Access Control   | IAM Roles & Policies, Security Groups |
| OS               | Amazon Linux 2 / Ubuntu              |

---

## 📁 Project Structure

```
aws-multitier-deployment/
├── main.tf                 # Root module - calls all sub-modules
├── variables.tf            # Input variables
├── outputs.tf              # Output values (IPs, ARNs, endpoints)
├── terraform.tfvars         # Variable values
├── provider.tf              # AWS provider configuration
│
├── modules/
│   ├── vpc/
│   │   ├── main.tf          # VPC, subnets, route tables, IGW, NAT
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── security/
│   │   ├── main.tf          # Security groups for web, app, db tiers
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── iam/
│   │   ├── main.tf          # IAM roles & instance profiles
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── ec2/
│   │   ├── main.tf          # Web tier & App tier EC2 instances
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── rds/
│   │   ├── main.tf          # Database subnet group, RDS instance
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── s3/
│       ├── main.tf          # S3 bucket for static assets
│       ├── variables.tf
│       └── outputs.tf
│
└── README.md
```

---

## 🌐 Networking Design

| Component        | CIDR / Detail            | Purpose                                  |
|-------------------|---------------------------|-------------------------------------------|
| VPC               | 10.0.0.0/16               | Isolated network environment             |
| Public Subnet     | 10.0.1.0/24               | Hosts web tier, ALB, NAT Gateway          |
| Private Subnet (App) | 10.0.2.0/24            | Hosts application tier                    |
| Private Subnet (DB)  | 10.0.3.0/24            | Hosts database tier                       |
| Internet Gateway  | Attached to VPC            | Allows public subnet internet access      |
| NAT Gateway       | In public subnet            | Allows private subnets outbound internet  |
| Route Tables      | Public & Private            | Direct traffic appropriately              |

---

## 🔐 Security Groups

| Security Group | Inbound Rules                                  | Source                  |
|------------------|--------------------------------------------------|---------------------------|
| Web-SG           | HTTP (80), HTTPS (443), SSH (22)                 | 0.0.0.0/0 (HTTP/HTTPS), restricted IP (SSH) |
| App-SG           | Custom app port (e.g., 8080)                     | Web-SG only               |
| DB-SG            | MySQL/PostgreSQL (3306/5432)                     | App-SG only               |

> 🔒 Each tier can only communicate with the tier directly above it — no direct public access to App or DB layers.

---

## 👤 IAM Roles (Least Privilege)

| Role            | Attached To  | Permissions                                  |
|------------------|---------------|------------------------------------------------|
| Web-S3-Role      | Web Tier EC2 | Read-only access to specific S3 bucket (static assets) |
| App-Role         | App Tier EC2 | Access to read DB credentials from Secrets Manager / SSM Parameter Store |

- No hardcoded credentials — all access via IAM instance profiles.
- Policies scoped to specific resource ARNs, not wildcard (`*`) access.

---

## 🪣 S3 — Static Asset Storage

- Bucket configured with **block public access** enabled by default.
- Web tier accesses the bucket via an IAM role (instance profile) — no access keys stored on the instance.
- Versioning enabled for asset rollback.

---

## ⚙️ Deployment Steps

### Prerequisites
- AWS account with programmatic access configured (`aws configure`)
- Terraform installed (v1.x+)
- An existing EC2 Key Pair (for SSH access, if required)

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/PurandharAchariBanthikatla/aws-multitier-deployment.git
cd aws-multitier-deployment

# 2. Initialize Terraform
terraform init

# 3. Review the execution plan
terraform plan -var-file="terraform.tfvars"

# 4. Apply the configuration
terraform apply -var-file="terraform.tfvars"

# 5. Destroy resources when done (to avoid charges)
terraform destroy -var-file="terraform.tfvars"
```

---

## 📤 Sample Outputs

After a successful `terraform apply`, the following outputs are displayed:

```
web_instance_public_ip = "x.x.x.x"
app_instance_private_ip = "10.0.2.x"
db_endpoint = "xxxx.rds.amazonaws.com"
s3_bucket_name = "multitier-static-assets-xxxx"
vpc_id = "vpc-xxxxxxxx"
```

---

## ✅ Key Learnings

- Designing a custom VPC with proper subnet segmentation (public vs. private)
- Implementing security group chaining to enforce tier-to-tier isolation
- Creating least-privilege IAM roles instead of using root/admin credentials
- Writing modular, reusable Terraform configurations
- Managing infrastructure lifecycle through code (plan → apply → destroy)

---

## 🚀 Future Improvements

- [ ] Add Auto Scaling Groups for Web and App tiers
- [ ] Implement Application Load Balancer with health checks
- [ ] Add CloudWatch monitoring & alarms
- [ ] Integrate with CI/CD pipeline (GitHub Actions) for automated `terraform plan/apply`
- [ ] Use AWS Secrets Manager for database credentials
- [ ] Enable Multi-AZ deployment for high availability

---

## 👨‍💻 Author

**Purandhar Achari Banthikatla**
DevOps & Cloud Engineering Trainee | AWS Certified Cloud Practitioner
GitHub: [PurandharAchariBanthikatla](https://github.com/PurandharAchariBanthikatla)

---

## 📄 License

This project is for educational/portfolio purposes.
