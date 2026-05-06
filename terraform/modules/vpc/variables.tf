variable "name" {
  type        = string
  description = "Resource name prefix"
}

variable "cidr_block" {
  type        = string
  description = "VPC CIDR block"
}

variable "public_subnets" {
  type = map(string)
  description = "Map of availability zones to public subnet CIDRs"
}

variable "private_app_subnets" {
  type = map(string)
  description = "Map of availability zones to private app subnet CIDRs"
}

variable "private_db_subnets" {
  type = map(string)
  description = "Map of availability zones to private DB subnet CIDRs"
}
