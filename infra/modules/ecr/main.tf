terraform {
  required_version = "~> 1.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.23"
    }
  }
}

//ecr repo
data "aws_ecr_repository" "app" {
  name = "ecs-threat-composer"
}