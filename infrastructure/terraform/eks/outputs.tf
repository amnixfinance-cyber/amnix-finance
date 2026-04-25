output "configure_kubectl" {
  description = "Configure kubectl command"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name}"
}
output "vpc_id" { value = module.vpc.vpc_id }
output "cluster_endpoint" { value = module.eks.cluster_endpoint }
output "cluster_oidc_issuer" { value = module.eks.oidc_provider_arn }
output "cluster_name" { value = module.eks.cluster_name }
