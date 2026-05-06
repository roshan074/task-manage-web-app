variable "zone_id" {
  type        = string
  description = "Route53 hosted zone ID"
}

variable "record_name" {
  type        = string
  description = "DNS record name"
}

variable "alb_dns_name" {
  type        = string
  description = "ALB DNS name for the Route53 alias"
}

variable "alb_zone_id" {
  type        = string
  description = "ALB zone ID used for alias record"
}
