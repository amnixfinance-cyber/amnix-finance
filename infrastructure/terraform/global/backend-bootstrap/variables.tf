variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "amnix-finance"
}

variable "tags" {
  type = map(string)
  default = {
    Project     = "amnix-finance"
    ManagedBy   = "terraform"
    Environment = "production"
  }
}
