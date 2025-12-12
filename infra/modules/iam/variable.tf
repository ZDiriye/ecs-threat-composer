variable "ecs_execution_role_name" {
  type    = string
  default = "ecsThreatComposerExecutionRole"
}

variable "ecs_execution_policy_arn" {
  type    = string
  default = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

variable "task_service_principals" {
  type    = list(string)
  default = ["ecs-tasks.amazonaws.com"]
}
