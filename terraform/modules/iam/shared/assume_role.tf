data "template_file" "assume_role_policy" {
  template = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${var.shared_account_id}:root"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:saml-provider/idp1"
      },
      "Action": "sts:AssumeRoleWithSAML",
      "Condition": {
        "StringEquals": {
          "SAML:aud": "https://signin.aws.amazon.com/saml"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role" "this" {
  count              = "${length(var.role_common_list)}"
  name               = "${var.environment}-${element(var.role_common_list, count.index)}"
  assume_role_policy = "${data.template_file.assume_role_policy.rendered}"
}

resource "aws_iam_policy" "this" {
  count = "${length(var.role_common_list)}"
  name  = "${var.environment}-${element(var.role_common_list, count.index)}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Resource": "arn:aws:iam::${var.main_account_id}:role/${var.environment}-${element(var.role_common_list, count.index)}"
  }
}
EOF
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = "${length(var.role_common_list)}"
  role       = "${aws_iam_role.this.*.name[count.index]}"
  policy_arn = "${aws_iam_policy.this.*.arn[count.index]}"
}
