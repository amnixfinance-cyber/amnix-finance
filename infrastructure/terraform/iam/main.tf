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

# ═══════════════════════════════════════════════════════════════
# Platform Tool IRSA Roles
# NOTE: oidc_provider_arn is PLACEHOLDER — update after EKS apply
# ═══════════════════════════════════════════════════════════════

# ─── Loki ────────────────────────────────────────────────────
resource "aws_iam_policy" "loki_s3" {
  name        = "amnix-finance-loki-s3"
  description = "Loki S3 read/write for chunks and ruler buckets"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject", "s3:GetObject", "s3:ListBucket",
        "s3:DeleteObject", "s3:GetBucketLocation"
      ]
      Resource = [
        "arn:aws:s3:::amnix-finance-*-loki-chunks",
        "arn:aws:s3:::amnix-finance-*-loki-chunks/*",
        "arn:aws:s3:::amnix-finance-*-loki-ruler",
        "arn:aws:s3:::amnix-finance-*-loki-ruler/*"
      ]
    }]
  })
  tags = { Project = "amnix-finance", ManagedBy = "terraform", Service = "loki" }
}

module "irsa_loki" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "amnix-finance-loki"

  oidc_providers = {
    eks = {
      provider_arn               = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/PLACEHOLDER"
      namespace_service_accounts = ["monitoring:loki"]
    }
  }

  role_policy_arns = { loki = aws_iam_policy.loki_s3.arn }

  tags = { Project = "amnix-finance", ManagedBy = "terraform", Service = "loki" }
}

# ─── Tempo ───────────────────────────────────────────────────
resource "aws_iam_policy" "tempo_s3" {
  name        = "amnix-finance-tempo-s3"
  description = "Tempo S3 read/write for traces bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject", "s3:GetObject", "s3:ListBucket",
        "s3:DeleteObject", "s3:GetBucketLocation"
      ]
      Resource = [
        "arn:aws:s3:::amnix-finance-*-tempo-traces",
        "arn:aws:s3:::amnix-finance-*-tempo-traces/*"
      ]
    }]
  })
  tags = { Project = "amnix-finance", ManagedBy = "terraform", Service = "tempo" }
}

module "irsa_tempo" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "amnix-finance-tempo"

  oidc_providers = {
    eks = {
      provider_arn               = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/PLACEHOLDER"
      namespace_service_accounts = ["monitoring:tempo"]
    }
  }

  role_policy_arns = { tempo = aws_iam_policy.tempo_s3.arn }

  tags = { Project = "amnix-finance", ManagedBy = "terraform", Service = "tempo" }
}

# ─── Velero ──────────────────────────────────────────────────
resource "aws_iam_policy" "velero" {
  name        = "amnix-finance-velero"
  description = "Velero S3 backup + EC2 snapshot permissions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject", "s3:DeleteObject", "s3:PutObject",
          "s3:AbortMultipartUpload", "s3:ListMultipartUploadParts"
        ]
        Resource = ["arn:aws:s3:::amnix-finance-*-velero-backups/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = ["arn:aws:s3:::amnix-finance-*-velero-backups"]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVolumes", "ec2:DescribeSnapshots",
          "ec2:CreateTags", "ec2:CreateVolume",
          "ec2:CreateSnapshot", "ec2:DeleteSnapshot"
        ]
        Resource = ["*"]
      }
    ]
  })
  tags = { Project = "amnix-finance", ManagedBy = "terraform", Service = "velero" }
}

module "irsa_velero" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "amnix-finance-velero"

  oidc_providers = {
    eks = {
      provider_arn               = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/PLACEHOLDER"
      namespace_service_accounts = ["velero:velero"]
    }
  }

  role_policy_arns = { velero = aws_iam_policy.velero.arn }

  tags = { Project = "amnix-finance", ManagedBy = "terraform", Service = "velero" }
}

# ─── Vault ───────────────────────────────────────────────────
resource "aws_iam_policy" "vault_kms" {
  name        = "amnix-finance-vault-kms"
  description = "Vault KMS auto-unseal permissions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["kms:Encrypt", "kms:Decrypt", "kms:DescribeKey"]
      Resource = ["*"]
      Condition = {
        StringEquals = {
          "kms:RequestAlias" = "alias/amnix-finance-vault-unseal"
        }
      }
    }]
  })
  tags = { Project = "amnix-finance", ManagedBy = "terraform", Service = "vault" }
}

module "irsa_vault" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "amnix-finance-vault"

  oidc_providers = {
    eks = {
      provider_arn               = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/PLACEHOLDER"
      namespace_service_accounts = ["vault:vault"]
    }
  }

  role_policy_arns = { vault_kms = aws_iam_policy.vault_kms.arn }

  tags = { Project = "amnix-finance", ManagedBy = "terraform", Service = "vault" }
}

# ─── External Secrets ────────────────────────────────────────
module "irsa_external_secrets" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                      = "amnix-finance-external-secrets"
  attach_external_secrets_policy = true

  oidc_providers = {
    eks = {
      provider_arn               = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/PLACEHOLDER"
      namespace_service_accounts = ["external-secrets:external-secrets"]
    }
  }

  tags = { Project = "amnix-finance", ManagedBy = "terraform", Service = "external-secrets" }
}
