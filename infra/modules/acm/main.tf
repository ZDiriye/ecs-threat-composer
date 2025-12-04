data "aws_acm_certificate" "issued" {
  domain   = "tm.zakariyediriye.com"
  types    = ["AMAZON_ISSUED"]
  most_recent = true
}