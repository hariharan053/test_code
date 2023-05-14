variable "region" {
}

variable "availability_zones" {
  type = list(string)
}

variable "aws_account_id" {
}

variable "environment" {
}

variable "instance_vpc_cidr_range" {
}

variable "vpc_cidr_range" {
  type = list
}

variable "vpc_id" {
}

variable "private_subnet" {
  type  = list(string)
}


variable "eks_cluster_name" {
}

variable "worker_instance_types" {
}

variable "workers_instance_count" {
}

variable "key_name" {
}


variable "fargate_enable" {
}
variable "eks_ami_id" {}

variable "efs_name" {}

variable "efs_role_name" {}

variable "efs_role_policy" {}

variable "s3_bucket" {}
