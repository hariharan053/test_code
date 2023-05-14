resource "aws_security_group" "cluster" {
  name        = format("%s-eks-cluster", var.environment)
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc-id
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = format("%s-eks-cluster", var.environment)
  }
}

resource "aws_security_group" "node" {
  depends_on = [aws_eks_cluster.main,aws_security_group.cluster]
  name        = format("%s-eks-node", var.environment)
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc-id
  tags = {
    "Name"  = format("%s-eks-node", var.environment)
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-ingress-cluster-run" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.node.id
  security_group_id        = aws_security_group.cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.node.id
  to_port                  = 443
  type                     = "ingress"
}


resource "aws_security_group_rule" "instance_cidr_cluster" {
  count             = length(var.instance_cidr)
  description       = "Allows Terraform instance https access to the cluster"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = var.instance_cidr
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "cluster-node-https" {
  description              = "Allow cluster to connect to node"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.cluster.id
  to_port                  = 443
  type                     = "ingress"
}


resource "aws_security_group_rule" "http-outbound" {
  description              = "Allow node to communicate with each other"
  from_port                = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  to_port                  = 80
  type                     = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "dns-outbound" {
  description              = "Allow DNS"
  from_port                = 53
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  to_port                  = 53
  type                     = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "dns-outbound-udp" {
  description              = "Allow DNS"
  from_port                = 53
  protocol                 = "udp"
  security_group_id        = aws_security_group.node.id
  to_port                  = 53
  type                     = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "atlas-outbound" {
  description              = "Atlas node port outbound"
  from_port                = 8085
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  to_port                  = 8085
  type                     = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-eks-node" {
  description              = "Allow node to communicate with each other"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  to_port                  = 443
  type                     = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "nfs-outbound" {
  description              = "Allow node to communicate with each other"
  from_port                = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  to_port                  = 2049
  type                     = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}



output "eks-worker-sg" {
  value = aws_security_group.node.id
}

output "eks-cluster-sg" {
  value = aws_security_group.cluster.id
}

