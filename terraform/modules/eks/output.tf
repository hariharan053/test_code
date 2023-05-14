output "cluster_sg" {
  value = aws_security_group.cluster.id
}

output "cluster_name" {
  value = aws_eks_cluster.main.id
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "worker_iam_arn" {
  value = aws_iam_role.node.arn
}

output "cluster_authority" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

output "eks_vpc_id" {
  value = aws_eks_cluster.main.vpc_config[0].vpc_id
}