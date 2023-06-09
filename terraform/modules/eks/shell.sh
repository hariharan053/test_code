#!/bin/bash
yum install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint ${aws_eks_cluster.main.endpoint} --b64-cluster-ca ${aws_eks_cluster.main.certificate_authority.0.data} ${var.cluster_name} >/tmp/out.txt
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
systemctl enable kubelet && systemctl start kubelet