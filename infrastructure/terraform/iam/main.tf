terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.34"
    }
  }
}


module "irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  for_each = toset([
    "auth", "ingestion", "processing", "realtime", "analytics",
    "search", "billing", "notifications", "feature-flags",
    "control-plane", "developer-portal", "tenant-operator",
    "hydration", "jobs", "ml-engine"
  ])

  role_name      = "amnix-finance-${each.key}"
  oidc_providers = ["arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/PLACEHOLDER"]
}
