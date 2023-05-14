resource "aws_iam_role" "this_common" {
  count              = "${length(var.role_common_list)}"
  name               = "${var.environment}-${element(var.role_common_list, count.index)}"
  assume_role_policy = "${data.template_file.assume_role_policy.rendered}"
}

resource "aws_iam_role" "this_restricted" {
  count              = "${length(var.role_restricted_list)}"
  name               = "${var.environment}-${element(var.role_restricted_list,count.index)}"
  assume_role_policy = "${data.template_file.assume_role_policy_restricted.rendered}"
}
