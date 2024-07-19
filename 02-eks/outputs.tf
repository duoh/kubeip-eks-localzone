output "eks_cluster_id" {
  value = module.eks.cluster_id
}

output "kubeip_role_arn" {
  value = module.kubeip_role.iam_role_arn
}
