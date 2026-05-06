variable "name" {
  type        = string
  description = "Cluster name prefix"
}

variable "cluster_role_arn" {
  type        = string
  description = "ARN of the IAM role for EKS cluster"
}

variable "cluster_role_name" {
  type        = string
  description = "Name of the IAM role for EKS cluster"
}

variable "node_role_arn" {
  type        = string
  description = "ARN of the IAM role for EKS worker nodes"
}

variable "private_app_subnet_ids" {
  type        = list(string)
  description = "Private subnets for EKS node groups"
}

variable "instance_types" {
  type        = list(string)
  description = "Instance types for the node group"
  default     = ["t3.medium"]
}

variable "capacity_type" {
  type        = string
  description = "Capacity type for the EKS node group"
  default     = "ON_DEMAND"
}

variable "node_desired_size" {
  type        = number
  description = "Desired node group size"
  default     = 3
}

variable "node_min_size" {
  type        = number
  description = "Minimum node group size"
  default     = 2
}

variable "node_max_size" {
  type        = number
  description = "Maximum node group size"
  default     = 6
}
