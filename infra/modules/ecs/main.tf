terraform {
  required_version = "~> 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.23"
    }
  }
}

//creates the ecs cluster
resource "aws_ecs_cluster" "ecs" {
  name = "ecs-threat-composer"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

//creates the cloudwatch log group
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/ecs-threat-composer"
  retention_in_days = 7
}

//creates the task definition
resource "aws_ecs_task_definition" "task_definition" {
  family                   = "ecs-threat-composer-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = var.task_cpu
  memory = var.task_memory

  execution_role_arn = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "ecs-threat-composer-app"
      image     = "${var.ecr_repo_url}:latest"
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  runtime_platform {
    operating_system_family = var.operating_system_family
    cpu_architecture        = var.cpu_architecture
  }
}

//creates the security group for the ecs tasks
resource "aws_security_group" "ecs_tasks" {
  name   = "ecs-tasks-sg"
  vpc_id = var.vpc_id

  ingress {
    description     = "Allow ALB to reach ECS tasks on 8080"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//creates the service
resource "aws_ecs_service" "service" {
  name                          = "ecs-threat-composer-task-service"
  cluster                       = aws_ecs_cluster.ecs.id
  task_definition               = aws_ecs_task_definition.task_definition.arn
  launch_type                   = "FARGATE"
  platform_version              = "LATEST"
  desired_count                 = 1
  availability_zone_rebalancing = "ENABLED"

  lifecycle {
    ignore_changes = [desired_count]
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets          = [var.private1_subnet_id, var.private2_subnet_id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "ecs-threat-composer-app"
    container_port   = var.container_port
  }
}