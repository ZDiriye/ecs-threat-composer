terraform {
  required_version = "~> 1.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.23"
    }
  }
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

//creates the ecs cluster
resource "aws_ecs_cluster" "ecs" {
  name = "ecs-threat-composer"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

//creates the task definition
resource "aws_ecs_task_definition" "task_definition" {
  family = "ecs-threat-composer-task"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"

  cpu       = var.task_cpu
  memory    = var.task_memory

  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  
  container_definitions = jsonencode([
    {
      name      = "ecs-threat-composer-app"
      image     = "${var.ecr_repo_url}:${var.image_tag}"
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
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
  name            = "ecs-threat-composer-task-service"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  launch_type     = "FARGATE"
  platform_version = "LATEST"
  desired_count   = 1
  availability_zone_rebalancing = "ENABLED"

  lifecycle {
    ignore_changes = [desired_count]
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets = [var.public1_subnet_id, var.public2_subnet_id]
    security_groups = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "ecs-threat-composer-app"
    container_port   = var.container_port
  }
}

//states the service auto scaling is for
resource "aws_appautoscaling_target" "ecs" {
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity

  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"

  resource_id = "service/${aws_ecs_cluster.ecs.name}/${aws_ecs_service.service.name}"
}

//scales the service according to cpu usage
resource "aws_appautoscaling_policy" "cpu_target" {
  name               = "cpu-target-tracking"
  policy_type        = "TargetTrackingScaling"

  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  resource_id        = aws_appautoscaling_target.ecs.resource_id

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.cpu_target
    scale_out_cooldown = var.scale_out_cooldown
    scale_in_cooldown  = var.scale_in_cooldown
  }
}