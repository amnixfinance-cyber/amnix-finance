terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.34"
    }
  }
}


locals {
  full_name = "amnix-finance-${var.environment}"
}

module "loki_bucket" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "~> 4.0"
  bucket        = "${local.full_name}-loki-logs"
  force_destroy = var.environment != "prod"

  lifecycle_rule = [{
    id         = "expire-old-logs"
    enabled    = true
    expiration = { days = var.loki_retention_days }
  }]
}

module "tempo_bucket" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "~> 4.0"
  bucket        = "${local.full_name}-tempo-traces"
  force_destroy = var.environment != "prod"

  lifecycle_rule = [{
    id         = "expire-old-traces"
    enabled    = true
    expiration = { days = var.tempo_retention_days }
  }]
}

module "mlflow_bucket" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "~> 4.0"
  bucket        = "${local.full_name}-mlflow-artifacts"
  force_destroy = var.environment != "prod"
}

module "velero_bucket" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "~> 4.0"
  bucket        = "${local.full_name}-velero-backups"
  force_destroy = false
}
