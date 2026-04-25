terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.34"
    }
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

  repository_name = "amnix-finance/${each.key}"

  repository_image_tag_mutability = "IMMUTABLE"
  repository_force_delete         = var.environment != "prod"
  repository_image_scan_on_push   = true

  tags = {
    Service     = each.key
    Environment = var.environment
  }
}
