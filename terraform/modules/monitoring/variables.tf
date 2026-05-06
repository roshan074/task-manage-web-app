variable "name" {
  type        = string
  description = "Resource name prefix for monitoring"
}

variable "retention_in_days" {
  type        = number
  default     = 30
}
