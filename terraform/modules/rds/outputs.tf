output "db_instance_identifier" {
  value = aws_db_instance.primary.id
}

output "db_endpoint" {
  value = aws_db_instance.primary.endpoint
}

output "db_port" {
  value = aws_db_instance.primary.port
}

output "db_subnet_group" {
  value = aws_db_subnet_group.this.name
}
