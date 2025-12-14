module "vpc" {
  source = "./modules/vpc"
}

module "ecr" {
  source = "./modules/ecr"
}

module "iam" {
  source = "./modules/iam"
}

module "ecs" {
  source                      = "./modules/ecs"
  ecr_repo_url                = module.ecr.ecr_repo_url
  private1_subnet_id          = module.vpc.private1_subnet_id
  private2_subnet_id          = module.vpc.private2_subnet_id
  vpc_id                      = module.vpc.vpc_id
  alb_sg_id                   = module.alb.alb_sg_id
  target_group_arn            = module.alb.target_group_arn
  depends_on                  = [module.alb]
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  image_tag                   = var.image_tag
}

module "alb" {
  source              = "./modules/alb"
  vpc_id              = module.vpc.vpc_id
  public1_subnet_id   = module.vpc.public1_subnet_id
  public2_subnet_id   = module.vpc.public2_subnet_id
  acm_certificate_arn = module.acm.acm_certificate_arn
}

module "acm" {
  source = "./modules/acm"
}