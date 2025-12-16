module "vpc" {
  source = "./modules/vpc"

  //subnets
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  //azs
  availability_zones = var.availability_zones
}

module "ecs" {
  source = "./modules/ecs"

  //cluster
  cluster_name = var.project_name

  //cloudwatch logs
  log_group_name        = "/ecs/${var.project_name}"
  log_retention_in_days = var.log_retention_in_days
  aws_region            = var.aws_region

  //task definition
  ecr_repo_url                = module.ecr.ecr_repo_url
  image_tag                   = var.image_tag
  task_family                 = "${var.project_name}-task"
  task_cpu                    = var.task_cpu
  task_memory                 = var.task_memory
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  container_name              = "${var.project_name}-app"
  container_port              = var.container_port
  operating_system_family     = var.operating_system_family
  cpu_architecture            = var.cpu_architecture

  //security group
  vpc_id    = module.vpc.vpc_id
  alb_sg_id = module.alb.alb_sg_id

  //service
  service_name                  = "${var.project_name}-task-service"
  desired_count                 = var.desired_count
  availability_zone_rebalancing = var.availability_zone_rebalancing
  private_subnets_id            = module.vpc.private_subnets_id
  target_group_arn              = module.alb.target_group_arn
}

module "alb" {
  source = "./modules/alb"

  //networking
  vpc_id            = module.vpc.vpc_id
  public_subnets_id = module.vpc.public_subnets_id

  //ACM certificate
  acm_certificate_arn = module.acm.acm_certificate_arn

  //listener and target group
  target_port          = var.target_port
  health_check_path    = var.health_check_path
  health_check_matcher = var.health_check_matcher
  ssl_policy           = var.ssl_policy

  //dns record
  zone_name   = var.zone_name
  record_name = var.record_name
  record_type = var.record_type

  //alb settings
  load_balancer_type = var.load_balancer_type
}

module "acm" {
  source = "./modules/acm"

  //certificate
  domain_name = var.domain_name

  //validation (route53)
  hosted_zone_name    = var.zone_name
  private_zone        = var.private_zone
  cert_validation_ttl = var.cert_validation_ttl
}

module "ecr" {
  source = "./modules/ecr"
}

module "iam" {
  source = "./modules/iam"

  ecs_execution_role_name  = var.ecs_execution_role_name
  ecs_execution_policy_arn = var.ecs_execution_policy_arn
  task_service_principals  = var.task_service_principals
}