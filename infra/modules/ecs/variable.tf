variable "ecr_repo_url" {
  type = string
}

variable "private1_subnet_id" {
  type = string
}

variable "private2_subnet_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "alb_sg_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "image_tag" {
  type    = string
}

variable "task_cpu" {
  type    = number
  default = 1024
}

variable "task_memory" {
  type    = number
  default = 3072
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "min_capacity" {
  type    = number
  default = 1
}

variable "max_capacity" {
  type    = number
  default = 4
}

variable "cpu_target" {
  type    = number
  default = 70
}

variable "scale_out_cooldown" {
  type    = number
  default = 300
}

variable "scale_in_cooldown" {
  type    = number
  default = 300
}

variable "operating_system_family" {
  type    = string
  default = "LINUX"
}

variable "cpu_architecture" {
  type    = string
  default = "ARM64"
}

variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "ecs_task_execution_role_arn" {
  type = string
}
