terraform {
  required_version = "~> 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.23"
    }
  }
}

//creates the ACM cert using DNS validation
resource "aws_acm_certificate" "cert" {
  domain_name       = "tm.zakariyediriye.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

//references Route53
data "aws_route53_zone" "zakariyediriye" {
  name         = "zakariyediriye.com"
  private_zone = false
}

//creates the record in the hosted zone for the domain on the ACM cert
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = data.aws_route53_zone.zakariyediriye.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 300
  allow_overwrite = true
}

//lets acm know the fully qualified domain names so it look it up and issue the cert if found
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}
