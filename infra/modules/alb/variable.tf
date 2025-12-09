variable "vpc_id" {
  type = string
}

variable "public1_subnet_id" {
  type = string
}

variable "public2_subnet_id" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}

variable "target_port" {
  type    = number
  default = 8080
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "health_check_matcher" {
  type    = string
  default = "200"
}

variable "ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "zone_name" {
  type    = string
  default = "zakariyediriye.com"
}

variable "record_name" {
  type    = string
  default = "tm"
}