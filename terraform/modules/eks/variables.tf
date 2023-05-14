variable "cluster_name" {
}

variable "vpc-id" {
}

variable "node_group_name" {
}

variable "private-subnets" {
  type = list(string)
}

#variable "public-subnets" {
# type = "list"
#}

variable "private_count" {
}

variable "environment" {
}

variable "worker_instance_types" {
  default = "m4.xlarge"
}

variable "workers_instance_count" {
  default = 3
}

variable "key_name" {
  default = ""
}

variable "ami_id" {
}

#variable "ossec_endpoint" {}
variable "fargate_enable" {
}

variable "ssh_group" {
  default = ""
}

variable "ssh_cidr" {
  type    = list(string)
  default = []
}

variable "write_kubeconfig" {
  description = "Whether to write a Kubectl config file containing the cluster configuration. Saved to `config_output_path`."
  default     = true
}

variable "manage_aws_auth" {
  description = "Whether to write and apply the aws-auth configmap file."
  default     = ""
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format."
  type        = list(string)
  default     = []
}

variable "map_accounts_count" {
  description = "The count of accounts in the map_accounts list."
  type        = string
  default     = 0
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format."
  type        = list(string)
  default     = []
}

variable "map_roles_count" {
  description = "The count of roles in the map_roles list."
  type        = string
  default     = 0
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format."
  type        = list(string)
  default     = []
}

variable "map_users_count" {
  description = "The count of roles in the map_users list."
  type        = string
  default     = 0
}

variable "config_output_path" {
  description = "Where to save the Kubectl config file (if `write_kubeconfig = true`). Should end in a forward slash `/` ."
  default     = "./eks-configs/"
}

variable "local_exec_interpreter" {
  description = "Command to run for local-exec resources. Must be a shell-style interpreter. If you are on Windows Git Bash is a good choice."
  type        = list(string)
  default     = ["/bin/bash", "-c"]
}

variable "kubeconfig_aws_authenticator_command_args" {
  description = "Default arguments passed to the authenticator command. Defaults to [token -i $cluster_name]."
  type        = list(string)
  default     = []
}

variable "kubeconfig_aws_authenticator_command" {
  description = "Command to use to fetch AWS EKS credentials."
  default     = "aws-iam-authenticator"
}

variable "kubeconfig_aws_authenticator_env_variables" {
  description = "Environment variables that should be used when executing the authenticator. e.g. { AWS_PROFILE = \"eks\"}."
  type        = map(string)
  default     = {}
}

variable "autojoin_policy_arn" {
  description = "Autojoin policy ARN"
  default     = ""
}

variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "jenkins_role_arn" {
  description = "Jenkins IAM role ARN"
  default     = ""
}

variable "domain" {
  description = "AD Domain name"
  default     = "concertohealth.ai"
}

variable "secret-id" {
  description = "Secrets manager ID containing AD creds"
  default     = "autojoin-ad-concertohealth"
}

variable "admin_role_arn" {
  default = "arn:aws:iam::537118560212:role/s3fullaccess"
}

#variable "s3_policy_arn" {}
#variable "sm_policy_arn" {}
#variable "glue_policy_arn" {}
#variable "sqs_policy_arn" {}

variable "instance_cidr" {
  type = list(string)
}

variable "eks_oidc_thumbprint" {
  description = "Thumbprint of Root CA for EKS OIDC, Valid until 2037"
  type        = string
  default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

variable s3_bucket {}