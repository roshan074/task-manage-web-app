resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.name}-redis-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = {
    Name = "${var.name}-redis-subnet-group"
  }
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id          = "${var.name}-redis"
  engine                        = "redis"
  engine_version                = var.engine_version
  node_type                     = var.node_type
  number_cache_clusters         = var.replication_count
  automatic_failover_enabled    = var.automatic_failover
  subnet_group_name             = aws_elasticache_subnet_group.this.name
  security_group_ids            = var.security_group_ids
  transit_encryption_enabled    = true
  at_rest_encryption_enabled    = true
  apply_immediately             = false
}
