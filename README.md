# ECS Threat Composer Deployment

This project is a complete AWS deployment of a containerised web application. It focuses on building the infrastructure using Terraform, packaging the app with Docker and automating deployments using GitHub Actions. The result is a live, production style setup deployed to AWS and accessible through a custom domain over HTTPS.

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

## Architecture
![AWS architecture diagram](images/architecture.png)

## Overview

## Terraform (Infrastructure)
Terraform provisions the AWS infrastructure in `infra/` using a modular setup.

#### Request flow
1. User enters `tm.zakariyediriye.com` in the browser.
2. Route 53 looks up the domain and returns the ALB DNS name.
3. If the request is HTTP, the ALB redirects it to HTTPS.
4. For HTTPS, the ALB performs the TLS handshake using the ACM cert then forwards the request to the target group which has the task IPs.
5. An ECS service manages tasks running in private subnets. The container receives traffic on port 8080 and logs are sent to CloudWatch.

#### Networking
- Creates a VPC with public and private subnets across 2 Availability Zones.
- Public subnets route to an Internet Gateway and private subnets use NAT Gateways for outbound access.

#### Load Balancing and DNS
- Creates an internet facing ALB with:
  - HTTP listener that redirects to HTTPS
  - HTTPS listener that forwards to the target group
- Creates a Route 53 alias A record pointing the subdomain to the ALB.

#### TLS (HTTPS)
- Requests an ACM certificate using DNS validation.
- Creates the validation records in Route 53 and completes certificate validation.

#### ECS
- Creates an ECS cluster.
- Creates the task definition.
- Creates an ECS service that manages tasks in private subnets.
- Tasks only accept inbound traffic from the ALB on port 8080.

#### IAM
- Creates the ECS task execution role used by tasks at runtime.

#### ECR
- Reads an existing ECR repository for the deployment.

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

## Local Setup
Run:
```bash
cd app
yarn install
yarn build
yarn global add serve
serve -s build
```
Then in your browser run:
```text
http://localhost:3000
```
### Local Health Check
After the local setup you can run a health check:
```bash
curl -f http://localhost:3000/health.json
```

## Live Domain Page

### Domain Page
![Domain Page](images/domain_page.png)

### ACM Certificate
![SSL Certificate](images/ssl_cert.png)