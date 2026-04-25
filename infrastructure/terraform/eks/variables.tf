variable "region" { default = "us-east-1" }
variable "cluster_name" { default = "amnix-finance-eks-dev" }
variable "environment" { default = "dev" }
variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "private_subnet_cidrs" { default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] }
variable "public_subnet_cidrs" { default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"] }
variable "cluster_version" { default = "1.32" }
variable "ami_type" { default = "AL2023_ARM_64_STANDARD" }
variable "service_accounts" {
  default = [
    "auth", "ingestion", "processing", "realtime", "analytics",
    "search", "billing", "notifications", "feature-flags",
    "control-plane", "developer-portal", "tenant-operator",
    "hydration", "jobs", "ml-engine"
  ]
}
