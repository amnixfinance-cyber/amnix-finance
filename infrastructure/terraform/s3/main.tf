terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.34"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_kms_key" "buckets" {
  description             = "amnix-finance S3 buckets encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = local.tags
}

resource "aws_kms_alias" "buckets" {
  name          = "alias/amnix-finance-s3"
  target_key_id = aws_kms_key.buckets.key_id
}

locals {
  full_name = "amnix-finance-${var.environment}"
  encryption = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.buckets.arn
      }
      bucket_key_enabled = true
    }
  }
  tags = {
    Project     = "amnix-finance"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "loki_chunks_bucket" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "~> 4.0"
  bucket        = "${local.full_name}-loki-chunks"
  force_destroy = var.environment != "prod"
  tags          = merge(local.tags, { Service = "loki" })
  server_side_encryption_configuration = local.encryption
  lifecycle_rule = [{
    id         = "expire-old-chunks"
    enabled    = true
    expiration = { days = var.loki_retention_days }
  }]
}

module "loki_ruler_bucket" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "~> 4.0"
  bucket        = "${local.full_name}-loki-ruler"
  force_destroy = var.environment != "prod"
  tags          = merge(local.tags, { Service = "loki" })
  server_side_encryption_configuration = local.encryption
}

module "tempo_bucket" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "~> 4.0"
  bucket        = "${local.full_name}-tempo-traces"
  force_destroy = var.environment != "prod"
  tags          = merge(local.tags, { Service = "tempo" })
  server_side_encryption_configuration = local.encryption
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
  tags          = merge(local.tags, { Service = "mlflow" })
  server_side_encryption_configuration = local.encryption
}

module "velero_bucket" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "~> 4.0"
  bucket        = "${local.full_name}-velero-backups"
  force_destroy = false
  tags          = merge(local.tags, { Service = "velero" })
  server_side_encryption_configuration = local.encryption
  versioning = {
    enabled = true
  }
}

module "cnpg_bucket" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "~> 4.0"
  bucket        = "${local.full_name}-cnpg-backups"
  force_destroy = false
  tags          = merge(local.tags, { Service = "cloudnativepg" })
  server_side_encryption_configuration = local.encryption
  versioning = {
    enabled = true
  }
}

module "risingwave_bucket" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "~> 4.0"
  bucket        = "${local.full_name}-risingwave-state"
  force_destroy = var.environment != "prod"
  tags          = merge(local.tags, { Service = "risingwave" })
  server_side_encryption_configuration = local.encryption
}
