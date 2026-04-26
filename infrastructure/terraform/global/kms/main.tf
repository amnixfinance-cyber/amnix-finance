terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.34"
    }
  }
}

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.0"

  description             = "KMS key for Vault auto-unseal – amnix-finance"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  aliases                 = ["amnix-finance-vault-unseal"]

  tags = {
    Project   = "amnix-finance"
    ManagedBy = "terraform"
    Usage     = "vault-unseal"
  }
}
