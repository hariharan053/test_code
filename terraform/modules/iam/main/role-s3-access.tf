locals {
  all_roles   = "${concat(var.role_common_list, var.role_restricted_list)}"
  bucket_arns = "${concat(aws_s3_bucket.this_common.*.arn, aws_s3_bucket.this_external.*.arn)}"
}

data "template_file" "object_arns" {
  count      = "${length(concat(var.buckets_external_list, var.buckets_common_list))}"
  template   = "${element(concat(aws_s3_bucket.this_common.*.arn, aws_s3_bucket.this_external.*.arn), count.index)}/*"
  depends_on = ["aws_s3_bucket.this_common", "aws_s3_bucket.this_external"]
}

data "aws_iam_policy_document" "this_s3" {
  statement {
    actions = [
      "S3:ListBuckets",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = [
      "S3:GetObject",
      "S3:ListObject",
      "S3:DeleteObject",
      "S3:PutObject",
    ]

    resources = ["${data.template_file.object_arns.*.rendered}"]
  }
}

resource "aws_iam_policy" "this_s3" {
  name   = "${var.environment}-s3"
  policy = "${data.aws_iam_policy_document.this_s3.json}"
}

resource "aws_iam_role_policy_attachment" "this_s3" {
  count      = "${length(local.all_roles)}"
  role       = "${var.environment}-${element(local.all_roles, count.index)}"
  policy_arn = "${aws_iam_policy.this_s3.arn}"
}
