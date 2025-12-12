terraform {
  required_version = "~> 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.23"
    }
  }
}

//creates the trust policy for the iam role
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = var.task_service_principals
    }
  }
}

//creates the iam role
resource "aws_iam_role" "ecs_execution_role" {
  name               = var.ecs_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

//attaches the permission to the iam
resource "aws_iam_role_policy_attachment" "ecs_exec_permissions" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = var.ecs_execution_policy_arn
}