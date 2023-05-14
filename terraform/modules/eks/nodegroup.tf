resource "aws_eks_node_group" "node" {
  #depends_on      = [aws_eks_cluster.main,aws_launch_template.this]
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private-subnets
  scaling_config {
    desired_size = var.workers_instance_count
    max_size     = var.workers_instance_count + 5
    min_size     = var.workers_instance_count
  }
  launch_template {
    id = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }
}

resource "aws_launch_template" "this" {
  name = "${var.environment}-eks-node"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 100
    }
  }

  ebs_optimized = true

  instance_type = var.worker_instance_types

  key_name = var.key_name
  image_id = var.ami_id
  vpc_security_group_ids = [aws_security_group.node.id]

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.environment}-node"
    }
  }

  #user_data = base64encode(local.userdata)
  user_data = base64encode(data.template_file.user_data_hw.rendered)
  #user_data = base64encode(local.userdata)
}

locals {
  userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.main.endpoint}' --b64-cluster-ca '${aws_eks_cluster.main.certificate_authority.0.data}' '${var.cluster_name}' >/tmp/out.txt
sudo yum update -y
sudo amazon-linux-extras install docker
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
setenforce 0
yum install -y kubelet
yum install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
systemctl enable kubelet
systemctl start kubelet
USERDATA
}

data "template_file" "user_data_hw" {
 template = <<EOF
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.main.endpoint}' --b64-cluster-ca '${aws_eks_cluster.main.certificate_authority.0.data}' '${var.cluster_name}' >/tmp/out.txt
sudo yum update -y
sudo amazon-linux-extras install docker
setenforce 0
yum install -y kubelet
yum install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
systemctl enable kubelet
systemctl start kubelet
EOF
}
