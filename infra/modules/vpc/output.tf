output "public1_subnet_id" {
  value = aws_subnet.public[0].id
}

output "public2_subnet_id" {
  value = aws_subnet.public[1].id
}

output "vpc_id" {
  value = aws_vpc.ecs.id
}
