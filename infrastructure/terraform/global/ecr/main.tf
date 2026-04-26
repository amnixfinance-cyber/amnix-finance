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

resource "aws_kms_key" "ecr" {
  description             = "amnix-finance ECR encryption key"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = local.tags
}

resource "aws_kms_alias" "ecr" {
  name          = "alias/amnix-finance-ecr"
  target_key_id = aws_kms_key.ecr.key_id
}

locals {
  tags = {
    Project     = "amnix-finance"
    ManagedBy   = "terraform"
    Environment = var.environment
  }
}

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.0"

  for_each = toset([
    "auth", "ingestion", "processing", "realtime", "analytics",
    "search", "billing", "notifications", "feature-flags",
    "control-plane", "developer-portal", "tenant-operator",
    "hydration", "jobs", "ml-engine"
  ])

  repository_name                 = "amnix-finance/${each.key}"
  repository_image_tag_mutability = "IMMUTABLE"
  repository_force_delete         = var.environment != "prod"
  repository_image_scan_on_push   = true

  repository_encryption_type = "KMS"
  repository_kms_key          = aws_kms_key.ecr.arn

  repository_lifecycle_policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 20 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 20
      }
      action = { type = "expire" }
    }]
  })

  tags = merge(local.tags, { Service = each.key })
}
