provider "aws" {
  alias  = "dr"
  region = "${var.replication_region}"
}

data "template_file" "replica_object_arns" {
  count      = "${length(concat(var.buckets_external_list, var.buckets_common_list))}"
  template   = "${element(concat(aws_s3_bucket.this_common.*.arn, aws_s3_bucket.this_external.*.arn), count.index)}-replica/*"
  depends_on = ["aws_s3_bucket.this_common", "aws_s3_bucket.this_external"]
}

resource "aws_iam_role" "replication" {
  name = "${var.environment}-s3-replication"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

data "aws_iam_policy_document" "s3_replication" {
  statement {
    actions = [
      "s3:Get*",
      "s3:ListBucket",
    ]

    resources = ["${concat(aws_s3_bucket.this_common.*.arn, aws_s3_bucket.this_external.*.arn)}"]
  }

  statement {
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
    ]

    resources = ["${data.template_file.object_arns.*.rendered}"]
  }

  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
    ]

    resources = ["${data.template_file.replica_object_arns.*.rendered}"]
  }
}

resource "aws_iam_policy" "replication" {
  name   = "${var.environment}-s3-replication"
  policy = "${data.aws_iam_policy_document.s3_replication.json}"
}

resource "aws_iam_policy_attachment" "replication" {
  name       = "${var.environment}-s3-replication"
  roles      = ["${aws_iam_role.replication.name}"]
  policy_arn = "${aws_iam_policy.replication.arn}"
}

resource "aws_s3_bucket" "destination_common" {
  provider = "aws.dr"
  count    = "${length(var.buckets_common_list)}"
  bucket   = "${var.environment}-${element(var.buckets_common_list, count.index)}-replica"
  region   = "${var.replication_region}"

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${var.dr_access_logs}"
    target_prefix = "${var.environment}-${element(var.buckets_common_list, count.index)}-replica/"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_notification" "destination_common" {
  provider = "aws.dr"
  count    = "${length(var.buckets_common_list)}"
  bucket   = "${aws_s3_bucket.destination_common.*.id[count.index]}"

  topic {
    topic_arn     = "${var.dr_sns_topic}"
    events        = ["s3:ObjectRemoved:*", "s3:ObjectRestore:Post", "s3:ObjectRestore:Completed"]
    filter_prefix = "${aws_s3_bucket.destination_common.*.id[count.index]}/"
    id            = "delete-restore"
  }
}

resource "aws_s3_bucket" "destination_external" {
  provider = "aws.dr"
  count    = "${length(var.buckets_external_list)}"
  bucket   = "${var.environment}-${element(var.buckets_external_list, count.index)}-replica"
  region   = "${var.replication_region}"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_notification" "destination_external" {
  provider = "aws.dr"
  count    = "${length(var.buckets_external_list)}"
  bucket   = "${aws_s3_bucket.destination_external.*.id[count.index]}"

  topic {
    topic_arn     = "${var.dr_sns_topic}"
    events        = ["s3:ObjectRemoved:*", "s3:ObjectRestore:Post", "s3:ObjectRestore:Completed"]
    filter_prefix = "${aws_s3_bucket.destination_external.*.id[count.index]}/"
    id            = "delete-restore"
  }
}

data "aws_iam_policy_document" "common_s3_policy_replica" {
  count = "${length(var.buckets_common_list)}"

  statement {
    actions = ["s3:*"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    resources = [
      "arn:aws:s3:::${var.environment}-${element(var.buckets_common_list, count.index)}-replica",
      "arn:aws:s3:::${var.environment}-${element(var.buckets_common_list, count.index)}-replica/*",
    ]
  }

  statement {
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]

    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::${var.environment}-${element(var.buckets_common_list, count.index)}-replica",
      "arn:aws:s3:::${var.environment}-${element(var.buckets_common_list, count.index)}-replica/*",
    ]

    condition {
      test     = "StringNotLike"
      variable = "aws:SourceVpce"
      values   = ["${var.vpc_endpoints}"]
    }
  }
}

data "aws_iam_policy_document" "external_s3_policy_replica" {
  count = "${length(var.buckets_external_list)}"

  statement {
    actions = ["s3:*"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    resources = [
      "arn:aws:s3:::${var.environment}-${element(var.buckets_external_list, count.index)}-replica",
      "arn:aws:s3:::${var.environment}-${element(var.buckets_external_list, count.index)}-replica/*",
    ]
  }

  statement {
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::${var.environment}-${element(var.buckets_external_list, count.index)}-replica",
      "arn:aws:s3:::${var.environment}-${element(var.buckets_external_list, count.index)}-replica/*",
    ]

    effect = "Deny"

    condition {
      test     = "StringNotLike"
      variable = "aws:SourceVpce"
      values   = ["${var.vpc_endpoints}"]
    }

    condition {
      test     = "StringNotLike"
      variable = "aws:SourceIp"
      values   = ["${var.allowed_ips}"]
    }
  }
}

resource "aws_s3_bucket_policy" "this_common_replica" {
  provider   = "aws.dr"
  count      = "${length(var.buckets_common_list)}"
  bucket     = "${var.environment}-${element(var.buckets_common_list, count.index)}-replica"
  policy     = "${data.aws_iam_policy_document.common_s3_policy_replica.*.json[count.index]}"
  depends_on = ["aws_s3_bucket_notification.destination_common"]
}

resource "aws_s3_bucket_policy" "this_external_replica" {
  provider   = "aws.dr"
  count      = "${length(var.buckets_external_list)}"
  bucket     = "${var.environment}-${element(var.buckets_external_list, count.index)}-replica"
  policy     = "${data.aws_iam_policy_document.external_s3_policy_replica.*.json[count.index]}"
  depends_on = ["aws_s3_bucket_notification.destination_external"]
}
