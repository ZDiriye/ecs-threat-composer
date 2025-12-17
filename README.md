# ECS Threat Composer Deployment

This project is a complete AWS deployment of a containerised web application. It focuses on building the infrastructure using Terraform, packaging the app with Docker and automating deployments using GitHub Actions. The result is a live, production style setup deployed to AWS and accessible through a custom domain over HTTPS.

## Architecture
![AWS architecture diagram](images/architecture.png)

## Overview

## Terraform (Infrastructure)
Terraform provisions the AWS infrastructure in `infra/` using a modular setup.

#### Request flow
1. User hits `tm.zakariyediriye.com` over HTTPS.
2. Route 53 routes traffic to the Application Load Balancer (ALB).
3. ALB redirects HTTP to HTTPS and forwards HTTPS traffic to the target group, which routes traffic to the Fargate tasks.
4. ECS/Fargate tasks run the container in private subnets and send logs to CloudWatch.

#### Networking
- Creates a VPC with public and private subnets across two Availability Zones.
- Public subnets have an Internet Gateway route and private subnets route outbound traffic through NAT Gateways.

#### Load Balancing and DNS
- Creates an internet facing ALB with:
  - HTTP listener that redirects to HTTPS
  - HTTPS listener that forwards to the target group
- Creates a Route 53 alias A record pointing the subdomain to the ALB.

#### SSL and HTTPS
- Requests an ACM certificate using DNS validation.
- Creates the validation records in Route 53 and completes certificate validation.

#### ECS
- Creates an ECS cluster.
- Defines a Fargate task definition for the container image from ECR, including CloudWatch logging.
- Creates an ECS service that manages Fargate tasks running in private subnets. The ALB forwards traffic to the tasks through the target group.
- Tasks only accept inbound traffic from the ALB on port 8080.

#### IAM
- Creates the ECS task execution role and attaches the required execution policy.

#### Container Registry reference
- Reads an existing ECR repository for use by the deployment.

## CI/CD Workflows (GitHub Actions)

All workflows run from this repo using GitHub Actions and authenticate to AWS using GitHub OIDC. Terraform workflows run from the `infra/` directory and require manual confirmation.

### Push to ECR workflow:
- Trigger: push to `main` when `app/` or `Dockerfile` changes or manual run with confirmation.
- Action: build Docker image and push to ECR.
- Tags: latest and the github SHA.

![Push to ECR](images/push_ecr.png)

### Terraform Plan workflow:
- Trigger: manual run with confirmation.
- Checks: `terraform fmt`, `terraform validate` and `tflint`.
- Action: `terraform plan`.

![Terraform Plan](images/tf_plan.png)

### Terraform Apply workflow:
- Trigger: manual run with confirmation.
- Action: `terraform apply -auto-approve`.
- Verify: wait 60s then `curl -f https://tm.zakariyediriye.com/health.json` to run a health check on the deployed application.

![Terraform Apply](images/tf_apply.png)

### Terraform Destroy workflow:
- Trigger: manual run with confirmation.
- Action: `terraform destroy -auto-approve`.

![Terraform Destroy](images/tf_destroy.png)

## Project Structure
```text
./
├── .github/
│   └── workflows/
│       ├── push-ecr.yaml
│       ├── tf-apply.yaml
│       ├── tf-destroy.yaml
│       └── tf-plan.yaml
├── app/
├── infra/
│   ├── main.tf
│   ├── provider.tf
│   ├── variable.tf
│   └── modules/
│       ├── acm/
│       ├── alb/
│       ├── ecr/
│       ├── ecs/
│       ├── iam/
│       └── vpc/
└── Dockerfile
```

## Local Setup
Run:
```bash
cd app
yarn install
yarn build
yarn global add serve
serve -s build
```
Then paste in your browser:
```text
http://localhost:3000
```
### Local Health Check
After the local setup, you can run a health check:
```bash
curl -f http://localhost:3000/health.json
```

## Live Domain and SSL

### Domain Page
![Domain Page](images/domain_page.png)

### ACM Certificate
![SSL Certificate](images/ssl_cert.png)