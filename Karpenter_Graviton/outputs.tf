output "eks_cluster_name" {
  value = module.eks.cluster_name
  description = "Name of the EKS cluster."
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
  description = "EKS cluster endpoint URL."
}
