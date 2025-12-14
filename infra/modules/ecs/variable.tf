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
  default = "10146ee604df77366a038ee10459fc56206eb506"
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

variable "operating_system_family" {
  type    = string
  default = "LINUX"
}

variable "cpu_architecture" {
  type    = string
  default = "X86_64"
}

variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "ecs_task_execution_role_arn" {
  type = string
}
