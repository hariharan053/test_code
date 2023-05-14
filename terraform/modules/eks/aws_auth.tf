locals {
  admin_role = [
    {
      role_arn = var.admin_role_arn
      username = "admin:{{SessionName}}"
      group    = "system:masters"
    },
    {
      role_arn = var.jenkins_role_arn
      username = "jenkins-admin"
      group    = "system:masters"
    },
  ]
}

resource "local_file" "config_map_aws_auth" {
  content  = data.template_file.config_map_aws_auth.rendered
  filename = "${var.config_output_path}config-map-aws-auth_${var.cluster_name}.yaml"
}

resource "null_resource" "update_config_map_aws_auth" {
  provisioner "local-exec" {
    command     = "for i in `seq 1 10`; do kubectl apply -f ${var.config_output_path}config-map-aws-auth_${var.cluster_name}.yaml --kubeconfig ${var.config_output_path}kubeconfig_${var.cluster_name} && exit 0 || sleep 10; done; exit 1"
    interpreter = var.local_exec_interpreter
  }

  triggers = {
    config_map_rendered = data.template_file.config_map_aws_auth.rendered
    endpoint            = aws_eks_cluster.main.endpoint
  }
}

resource "null_resource" "copy_kube_config" {
  count      = var.fargate_enable == "true" ? 1 : 0
  depends_on = [null_resource.update_config_map_aws_auth]
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "cat ${var.config_output_path}kubeconfig_${var.cluster_name} >> ~/.kube/config"
  }
}

data "template_file" "worker_role_arns" {
  template = file("${path.module}/templates/worker-role.tpl")

  vars = {
    worker_role_arn = "arn:aws:iam::667449102875:role/default-instance-role"
  }
}

data "template_file" "config_map_aws_auth" {
  template = file("${path.module}/templates/config-map-aws-auth.yaml.tpl")

  vars = {
    worker_role_arn = data.template_file.worker_role_arns.rendered
    map_roles       = join("", data.template_file.map_roles.*.rendered)
    jenkins_roles   = join("", data.template_file.jenkins_roles.*.rendered)
  }
}

data "template_file" "map_roles" {
  template = file(
    "${path.module}/templates/config-map-aws-auth-map_roles.yaml.tpl",
  )

  vars = {
    role_arn = local.admin_role[0]["role_arn"]
    username = local.admin_role[0]["username"]
    group    = local.admin_role[0]["group"]
  }
}

data "template_file" "jenkins_roles" {
  template = file(
    "${path.module}/templates/config-map-aws-auth-map_roles.yaml.tpl",
  )

  vars = {
    role_arn = local.admin_role[1]["role_arn"]
    username = local.admin_role[1]["username"]
    group    = local.admin_role[1]["group"]
  }
}

