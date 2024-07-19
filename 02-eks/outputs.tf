output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "kubeip_role_arn" {
  value = module.kubeip_role.iam_role_arn
}