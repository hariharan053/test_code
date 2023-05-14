resource "null_resource" "tag-vpc" {
  count = var.private_count
  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${var.private-subnets[count.index]} --tags Key=kubernetes.io/cluster/${var.cluster_name},Value=shared Key=kubernetes.io/role/internal-elb,Value=1 --region ${var.region}"
  }
}

