resource "local_file" "kubeconfig" {
  content  = data.template_file.kubeconfig.rendered
  filename = "${var.config_output_path}kubeconfig_${var.cluster_name}"
}

data "template_file" "kubeconfig" {
  template = file("${path.module}/templates/kubeconfig.tpl")

  vars = {
    kubeconfig_name           = var.cluster_name
    endpoint                  = aws_eks_cluster.main.endpoint
    region                    = var.region
    cluster_auth_base64       = aws_eks_cluster.main.certificate_authority[0].data
    aws_authenticator_command = var.kubeconfig_aws_authenticator_command
    aws_authenticator_command_args = length(var.kubeconfig_aws_authenticator_command_args) > 0 ? "        - ${join(
      "\n        - ",
      var.kubeconfig_aws_authenticator_command_args,
      )}" : "        - ${join(
      "\n        - ",
      formatlist("\"%s\"", ["token", "-i", var.cluster_name]),
    )}"
    aws_authenticator_env_variables = length(var.kubeconfig_aws_authenticator_env_variables) > 0 ? "      env:\n${join(
      "\n",
      data.template_file.aws_authenticator_env_variables.*.rendered,
    )}" : ""
  }
}

data "template_file" "aws_authenticator_env_variables" {
  template = <<EOF
        - name: $${key}
          value: $${value}
EOF


  count = length(var.kubeconfig_aws_authenticator_env_variables)

  vars = {
    value = element(
      values(var.kubeconfig_aws_authenticator_env_variables),
      count.index,
    )
    key = element(
      keys(var.kubeconfig_aws_authenticator_env_variables),
      count.index,
    )
  }
}

