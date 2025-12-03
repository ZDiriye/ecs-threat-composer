output "public1_subnet_id" {
  value = aws_subnet.public1.id
}

output "public2_subnet_id" {
  value = aws_subnet.public2.id
}

output "vpc_id" {
  value = aws_vpc.ecs.id
}
