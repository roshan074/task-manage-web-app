variable "name" {
  type        = string
  description = "Resource name prefix"
}

variable "private_db_subnet_ids" {
  type        = list(string)
  description = "Private DB subnet IDs"
}

variable "engine_version" {
  type        = string
  default     = "15.4"
}

variable "instance_class" {
  type        = string
  default     = "db.r6g.large"
}

variable "username" {
  type        = string
}

variable "password" {
  type        = string
  sensitive   = true
}

variable "allocated_storage" {
  type        = number
  default     = 100
}

variable "storage_type" {
  type        = string
  default     = "gp3"
}

variable "multi_az" {
  type        = bool
  default     = true
}

variable "security_group_ids" {
  type        = list(string)
}

variable "backup_retention_days" {
  type        = number
  default     = 7
}
