variable "image_tag" {
  type    = string
  default = "5bf734f"
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

  cpu       = "1024"
  memory    = "3072"

  execution_role_arn  = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  task_role_arn    = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  
  container_definitions = jsonencode([
    {
      name      = "ecs-threat-composer-app"
      image     = "${var.ecr_repo_url}:${var.image_tag}"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
    }
  ])
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

//ecs tasks security group
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


//service
resource "aws_ecs_service" "service" {
  name            = "ecs-threat-composer-task-service"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  launch_type     = "FARGATE"
  platform_version = "LATEST"
  desired_count   = 1
  availability_zone_rebalancing = "ENABLED"

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
    container_port   = 8080
  }

  //prevents race condition
  depends_on = [ var.aws_lb_listener_arn ]
}