//ecr repo
data "aws_ecr_repository" "app" {
  name = "ecs-threat-composer"
}