module "vpc" {
  source = "./modules/vpc"
}

module "ecr" {
  source = "./modules/ecr"
}

module "ecs" {
  source = "./modules/ecs"
  ecr_repo_url = module.ecr.ecr_repo_url
  public1_subnet_id = module.vpc.public1_subnet_id
  public2_subnet_id = module.vpc.public2_subnet_id
  vpc_id = module.vpc.vpc_id
  alb_sg_id = module.alb.alb_sg_id
}

module "alb" {
  source = "./modules/alb"
  vpc_id = module.vpc.vpc_id
}
