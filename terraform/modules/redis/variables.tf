variable "name" {
  type        = string
  description = "Resource name prefix"
}

variable "private_db_subnet_ids" {
  type        = list(string)
  description = "Private DB subnet IDs for Redis"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security groups allowed to access Redis"
}

variable "engine_version" {
  type        = string
  default     = "7.0"
}

variable "node_type" {
  type        = string
  default     = "cache.t4g.small"
}

variable "replication_count" {
  type        = number
  default     = 2
}

variable "automatic_failover" {
  type        = bool
  default     = true
}
