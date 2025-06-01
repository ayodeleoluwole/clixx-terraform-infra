# CliXX Retail — AWS Infrastructure

---

## Overview

This project provisions a fully automated, highly available AWS infrastructure stack for a WordPress application. EC2 instances are launched via an Auto Scaling Group, share a common EFS filesystem, connect to an RDS database restored from snapshot, and are served through an Application Load Balancer. All instance configuration is handled automatically via a bootstrap script at launch.

---

## Prerequisites

- Terraform >= 0.12
- An active AWS account
- AWS CLI installed and configured
- An existing RDS snapshot named `clixx-retaildb`
- An existing EC2 key pair public key file (`test_instances_kp.pub`)

---

## Infrastructure

| Resource | Description |
|---|---|
| **VPC** | Custom VPC (`10.0.0.0/16`) with 2 public and 2 private subnets across availability zones |
| **Internet Gateway** | Routes inbound traffic to public subnets |
| **NAT Gateways** | One per AZ — allows private subnet instances to reach the internet |
| **ALB** | Internet-facing Application Load Balancer with HTTP listener and health checks |
| **ASG** | Auto Scaling Group (min 1, max 3) with CPU-based target tracking at 50% |
| **Launch Template** | EC2 launch configuration with bootstrap user data injected at runtime |
| **EFS** | Encrypted Elastic File System mounted at `/var/www/html` across all EC2 instances |
| **RDS** | MySQL database instance restored from snapshot, isolated in private subnets |
| **S3** | Versioned Terraform state bucket with destroy protection enabled |
| **Security Groups** | Layered — ALB → EC2 → EFS/RDS; no direct internet access to private resources |

---

## Security Architecture

```
Internet
    │
   ALB (port 80/443)
    │
   EC2 (port 80 from ALB only)
    │
   ├── EFS (port 2049 from EC2 only)
    │
   └── RDS (port 3306 from EC2 only)
```

No private resource is directly accessible from the internet.

---

## Bootstrap Script

On launch, each EC2 instance automatically:

1. Installs Apache, PHP 8.2, MariaDB client, Git, and EFS utilities
2. Mounts the EFS volume at `/var/www/html`
3. Clones the CliXX Retail WordPress application from GitHub
4. Configures `wp-config.php` with RDS credentials pulled from AWS Secrets Manager
5. Updates the WordPress site URL in RDS
6. Starts and enables Apache

---

## Project Structure

```
clixx-retail-aws-infrastructure/
├── vpc.tf                  # VPC, subnets, IGW, NAT gateways, route tables
├── security_group.tf       # ALB, EC2, EFS, and RDS security groups
├── ALB.tf                  # Load balancer, target group, listener, ASG attachment
├── ASG.tf                  # Auto Scaling Group and scaling policy
├── launch_template.tf      # EC2 launch template and key pair
├── efs.tf                  # EFS file system and mount targets
├── rds.tf                  # RDS instance restored from snapshot
├── s3.tf                   # Terraform state bucket
├── data.tf                 # Data sources — bootstrap template, RDS snapshot, AZs
├── backend.tf              # S3 remote state backend configuration
├── ouput.tf                # ALB DNS name output
├── vars.tf                 # Input variables
├── versions.tf             # Terraform version constraint
└── scripts/
    └── clixx_bootstrap.tpl # EC2 user data bootstrap script
```

---

## Usage

```bash
git clone https://github.com/ayodeleoluwole/clixx-retail-aws-infrastructure.git
cd clixx-retail-aws-infrastructure

# Initialise Terraform and configure remote state
terraform init

# Preview the infrastructure plan
terraform plan

# Deploy
terraform apply
```

Once deployed, the ALB DNS name is returned as an output:

```bash
terraform output lb_endpoint
```

---

## Variables

| Variable | Default | Description |
|---|---|---|
| `AWS_REGION` | `us-east-2` | Target AWS region |
| `instance_type` | `t3.micro` | EC2 instance type |
| `ami` | `ami-0b671272c81662a99` | Base AMI ID |
| `PATH_TO_PUBLIC_KEY` | `test_instances_kp.pub` | Path to EC2 key pair public key |

---

## Remote State

Terraform state is stored remotely in S3:

```
Bucket : mystatefile-clixxretail
Key    : base-infrastructure/terraform.tfstate
Region : us-east-2
```

---

## Roadmap

- [ ] HTTPS listener with ACM certificate
- [ ] Move DB credentials to AWS Secrets Manager
- [ ] Add CloudWatch alarms for ASG and RDS monitoring
- [ ] Enable RDS multi-AZ for high availability
- [ ] Add WAF to ALB for web application security

---

> Infrastructure as code for engineers who build for scale.