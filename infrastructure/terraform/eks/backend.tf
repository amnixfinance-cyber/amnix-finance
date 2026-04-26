terraform {
  backend "s3" {
    bucket         = "amnix-finance-terraform-state-YOUR_AWS_ACCOUNT_ID"
    key            = "infrastructure/terraform/eks/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "amnix-finance-terraform-locks"
  }
}
