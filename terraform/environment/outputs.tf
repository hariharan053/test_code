output "eks_endpoint" {
  description = "EKS Endpoint"
  value       = module.eks-web.cluster_endpoint
}

output "efs_id" {
  description = "EFS ID"
  value       = module.efs.id
}

output "cluster_name" {
  value = module.eks-web.cluster_name
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "efs_role_name" {
  value = var.efs_role_name
}

output "efs_role_policy" {
  value = var.efs_role_policy
}

output "region" {
  value = var.region
}