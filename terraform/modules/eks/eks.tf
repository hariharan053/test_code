resource "aws_eks_cluster" "main" {
  name                      = var.cluster_name
  role_arn                  = "${aws_iam_role.cluster.arn}"
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  vpc_config {
    security_group_ids      = [aws_security_group.cluster.id]
    subnet_ids              = var.private-subnets
    endpoint_public_access  = "false"
    endpoint_private_access = "true"
  }

  lifecycle {
    ignore_changes = [role_arn]
  }
}

/*
data "aws_region" "current" {}
# Fetch OIDC provider thumbprint for root CA
data "external" "thumbprint" {
  program = ["../../../modules/eks/oidc-thumbprint.sh"]
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.external.thumbprint.result.thumbprint]
  url             = aws_eks_cluster.main.identity.0.oidc.0.issuer
}
*/

## OIDC config

data "aws_region" "current" {}