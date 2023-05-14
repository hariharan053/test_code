module "eks-web" {
  source                    = "../modules/eks"
  cluster_name              = var.eks_cluster_name
  environment               = var.environment
  vpc-id                    = var.vpc_id
  private-subnets           = var.private_subnet
  private_count             = "3"
  worker_instance_types     = var.worker_instance_types
  workers_instance_count    = "3"
  key_name                  = var.key_name
  ami_id                    = var.eks_ami_id
  manage_aws_auth           = true
  write_kubeconfig          = true
  instance_cidr             = [var.instance_vpc_cidr_range]
  fargate_enable            = "false"
  node_group_name           = "eks-nodegroup"
  s3_bucket                 = var.s3_bucket
}

