resource "aws_iam_policy" "this" {
  count  = "${length(var.role_restricted_list)}"
  name   = "${var.environment}-${element(var.role_restricted_list,count.index)}"
  policy = "${file("${path.module}/templates/${element(var.role_restricted_list, count.index)}.json")}"
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = "${length(var.role_restricted_list)}"
  role       = "${aws_iam_role.this_restricted.*.name[count.index]}"
  policy_arn = "${aws_iam_policy.this.*.arn[count.index]}"
}
