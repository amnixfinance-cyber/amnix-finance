output "configure_kubectl" {
  description = "Configure kubectl command"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name}"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_oidc_issuer" {
  value = module.eks.oidc_provider_arn
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "karpenter_node_role_name" {
  description = "Required for Karpenter EC2NodeClass in Layer 1"
  value       = module.karpenter.node_iam_role_name
}

output "karpenter_queue_name" {
  description = "Required for Karpenter EC2NodeClass spot interruption"
  value       = module.karpenter.queue_name
}
