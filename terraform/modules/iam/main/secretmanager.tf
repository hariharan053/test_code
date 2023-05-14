resource "aws_secretsmanager_secret" "this_redshift" {
  count                   = "${length(var.redshift_roles)}"
  name                    = "${var.environment}-${element(var.redshift_roles, count.index)}"
  recovery_window_in_days = "0"
}

resource "aws_secretsmanager_secret_version" "this_redshift" {
  count         = "${length(var.redshift_roles)}"
  secret_id     = "${aws_secretsmanager_secret.this_redshift.*.id[count.index]}"
  secret_string = "placeholder redshift"
}

data "aws_iam_policy_document" "this_redshift" {
  count = "${length(var.redshift_roles)}"

  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage",
    ]

    resources = [
      "${aws_secretsmanager_secret.this_redshift.*.arn[count.index]}",
    ]
  }
}

resource "aws_iam_policy" "this_redshift" {
  count  = "${length(var.redshift_roles)}"
  name   = "${var.environment}-${element(var.redshift_roles, count.index)}-redshift"
  policy = "${data.aws_iam_policy_document.this_redshift.*.json[count.index]}"
}

resource "aws_iam_role_policy_attachment" "this_redshift" {
  count      = "${length(var.redshift_roles)}"
  role       = "${var.environment}-${element(var.redshift_roles, count.index)}"
  policy_arn = "${aws_iam_policy.this_redshift.*.arn[count.index]}"
}

resource "aws_secretsmanager_secret" "this_postgres" {
  count                   = "${length(var.postgres_roles)}"
  name                    = "${var.environment}-${element(var.postgres_roles, count.index)}"
  recovery_window_in_days = "0"
}

resource "aws_secretsmanager_secret_version" "this_postgres" {
  count         = "${length(var.postgres_roles)}"
  secret_id     = "${aws_secretsmanager_secret.this_postgres.*.id[count.index]}"
  secret_string = "placeholder postgres"
}

data "aws_iam_policy_document" "this_postgres" {
  count = "${length(var.postgres_roles)}"

  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage",
    ]

    resources = [
      "${aws_secretsmanager_secret.this_postgres.*.arn[count.index]}",
    ]
  }
}

resource "aws_iam_policy" "this_postgres" {
  count  = "${length(var.postgres_roles)}"
  name   = "${var.environment}-${element(var.postgres_roles, count.index)}-postgres"
  policy = "${data.aws_iam_policy_document.this_postgres.*.json[count.index]}"
}

resource "aws_iam_role_policy_attachment" "this_postgres" {
  count      = "${length(var.postgres_roles)}"
  role       = "${var.environment}-${element(var.postgres_roles, count.index)}"
  policy_arn = "${aws_iam_policy.this_postgres.*.arn[count.index]}"
}
