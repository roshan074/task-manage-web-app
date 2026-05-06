variable "eks_cluster_role_arn" {
  type        = string
  description = "EKS cluster IAM role ARN"
}

variable "eks_cluster_role_name" {
  type        = string
  description = "EKS cluster IAM role name"
}

variable "eks_node_role_arn" {
  type        = string
  description = "EKS node group IAM role ARN"
}

variable "db_username" {
  type        = string
  description = "PostgreSQL admin username"
}

variable "db_password" {
  type        = string
  description = "PostgreSQL admin password"
  sensitive   = true
}

variable "db_security_group_ids" {
  type        = list(string)
  description = "Security group IDs for PostgreSQL"
}

variable "redis_security_group_ids" {
  type        = list(string)
  description = "Security group IDs for Redis"
}
