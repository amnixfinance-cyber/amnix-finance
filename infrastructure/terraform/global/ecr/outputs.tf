output "ecr_repository_urls" {
  value = { for k, v in module.ecr : k => v.repository_url }
}
