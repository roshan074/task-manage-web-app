provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source = "../../modules/vpc"

  name               = "fintech-prod"
  cidr_block         = "10.0.0.0/16"
  public_subnets     = {
    "ap-south-1a" = "10.0.1.0/24"
    "ap-south-1b" = "10.0.2.0/24"
    "ap-south-1c" = "10.0.3.0/24"
  }
  private_app_subnets = {
    "ap-south-1a" = "10.0.11.0/24"
    "ap-south-1b" = "10.0.12.0/24"
    "ap-south-1c" = "10.0.13.0/24"
  }
  private_db_subnets = {
    "ap-south-1a" = "10.0.21.0/24"
    "ap-south-1b" = "10.0.22.0/24"
    "ap-south-1c" = "10.0.23.0/24"
  }
}

module "eks" {
  source = "../../modules/eks"

  name                   = "fintech-prod"
  cluster_role_arn       = "${var.eks_cluster_role_arn}"
  cluster_role_name      = "${var.eks_cluster_role_name}"
  node_role_arn          = "${var.eks_node_role_arn}"
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
  instance_types         = ["t3.large"]
  capacity_type          = "ON_DEMAND"
}

module "rds" {
  source = "../../modules/rds"

  name                 = "fintech-prod"
  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  username             = var.db_username
  password             = var.db_password
  security_group_ids   = var.db_security_group_ids
}

module "redis" {
  source = "../../modules/redis"

  name                 = "fintech-prod"
  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  security_group_ids   = var.redis_security_group_ids
}
