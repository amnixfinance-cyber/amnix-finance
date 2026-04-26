# !!! IMPORTANT !!!
# OIDC ARN below is a PLACEHOLDER.
# Replace after EKS apply: terraform output -raw cluster_oidc_issuer
# Then update oidc_provider_arn and run terraform apply

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

  role_name = "amnix-finance-${each.key}"

  oidc_providers = {
    eks = {
      provider_arn               = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/PLACEHOLDER"
      namespace_service_accounts = ["${each.key}:amnix-finance-${each.key}"]
    }
  }

  # Service-specific policies are attached per service after deployment.
  # Each service team is responsible for defining their own role_policy_arns.
  tags = {
    Project   = "amnix-finance"
    ManagedBy = "terraform"
    Service   = each.key
  }
}
