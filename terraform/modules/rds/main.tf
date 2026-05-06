resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = {
    Name = "${var.name}-db-subnet-group"
  }
}

resource "aws_db_instance" "primary" {
  identifier              = "${var.name}-postgresql"
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  username                = var.username
  password                = var.password
  allocated_storage       = var.allocated_storage
  storage_type            = var.storage_type
  multi_az                = var.multi_az
  publicly_accessible     = false
  vpc_security_group_ids  = var.security_group_ids
  db_subnet_group_name    = aws_db_subnet_group.this.name
  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = var.backup_retention_days
}
