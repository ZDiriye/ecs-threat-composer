//ecr repo
data "aws_ecr_repository" "app" {
  name = "ecs-threat-composer"
}

// make the above an output to get the repo url and use for the ecs task defintion