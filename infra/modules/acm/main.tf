terraform {
  required_version = "~> 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.23"
    }
  }
}


data "aws_acm_certificate" "issued" {
  domain      = "tm.zakariyediriye.com"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}