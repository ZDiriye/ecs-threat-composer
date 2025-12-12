variable "domain_name" {
  type    = string
  default = "tm.zakariyediriye.com"
}

variable "hosted_zone_name" {
  type    = string
  default = "zakariyediriye.com"
}

variable "private_zone" {
  type    = bool
  default = false
}

variable "cert_validation_ttl" {
  type    = number
  default = 300
}
