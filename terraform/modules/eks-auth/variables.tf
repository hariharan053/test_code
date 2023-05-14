variable "config_output_path" {
  description = "Where to save the Kubectl config file (if `write_kubeconfig = true`). Should end in a forward slash `/` ."
  default     = "./eks-configs/"
}

variable "cluster-name" {}

variable "local_exec_interpreter" {
  description = "Command to run for local-exec resources. Must be a shell-style interpreter. If you are on Windows Git Bash is a good choice."
  type        = "list"
  default     = ["/bin/bash", "-c"]
}

variable "kubeconfig_aws_authenticator_command_args" {
  description = "Default arguments passed to the authenticator command. Defaults to [token -i $cluster_name]."
  type        = "list"
  default     = []
}

variable "kubeconfig_aws_authenticator_command" {
  description = "Command to use to fetch AWS EKS credentials."
  default     = "aws-iam-authenticator"
}

variable "kubeconfig_aws_authenticator_env_variables" {
  description = "Environment variables that should be used when executing the authenticator. e.g. { AWS_PROFILE = \"eks\"}."
  type        = "map"
  default     = {}
}

variable "region" {
  description = "AWS Region"
  deafult = "us-east-1"
}

variable "eks_endpoint" {
  description = "EKS Cluster endpoint"
}

variable "eks_certificate_authority" {
  description = "EKS Cluster authority data"
}

variable "worker_role_arn" {
  description = "EKS worker role arn"
}

variable "jenkins_role_arn" {
  description = "Jenkins IAM role ARN"
}

variable "admin_role_arn" {
  description = "Admin IAM role ARN"
}