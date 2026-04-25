terraform {
  backend "s3" {
    bucket         = "amnix-finance-terraform-state-dev"
    key            = "infrastructure/terraform/global/ecr/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "amnix-finance-terraform-locks"
  }
}
