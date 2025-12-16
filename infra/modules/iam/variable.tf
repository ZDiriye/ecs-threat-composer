variable "ecs_execution_role_name" {
  type = string
}

variable "ecs_execution_policy_arn" {
  type = string
}

variable "task_service_principals" {
  type = list(string)
}
