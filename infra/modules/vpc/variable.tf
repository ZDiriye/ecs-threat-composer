variable "public_subnet_cidrs" {
  type = list
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  type = list
  default = ["eu-west-2a", "eu-west-2b"]
}