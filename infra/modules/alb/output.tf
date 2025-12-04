output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "target_group_arn" {
  value = aws_lb_target_group.alb.arn
}

output "aws_lb_listener_arn" {
  value = aws_lb_listener.https.arn
}