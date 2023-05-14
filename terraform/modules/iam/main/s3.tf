resource "aws_s3_bucket" "this_common" {
  count         = "${length(var.buckets_common_list)}"
  bucket        = "${var.environment}-${element(var.buckets_common_list, count.index)}"
  acl           = "private"
  region        = "${var.region}"
  force_destroy = true

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${var.access_log_bucket}"
    target_prefix = "${var.environment}-${element(var.buckets_common_list, count.index)}/"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  replication_configuration {
    role = "${aws_iam_role.replication.arn}"

    rules {
      id     = "${var.environment}-${element(var.buckets_common_list, count.index)}"
      status = "Enabled"

      destination {
        bucket        = "${aws_s3_bucket.destination_common.*.arn[count.index]}"
        storage_class = "STANDARD"
      }
    }
  }
}

resource "aws_s3_bucket_notification" "this_common" {
  count  = "${length(var.buckets_common_list)}"
  bucket = "${aws_s3_bucket.this_common.*.id[count.index]}"

  topic {
    topic_arn     = "${var.sns_topic_arn}"
    events        = ["s3:ObjectRemoved:*", "s3:ObjectRestore:Post", "s3:ObjectRestore:Completed"]
    filter_prefix = "${aws_s3_bucket.this_common.*.id[count.index]}/"
    id            = "delete-restore"
  }
}

resource "aws_s3_bucket" "this_external" {
  count         = "${length(var.buckets_external_list)}"
  bucket        = "${var.environment}-${element(var.buckets_external_list, count.index)}"
  acl           = "private"
  region        = "${var.region}"
  force_destroy = true

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${var.access_log_bucket}"
    target_prefix = "${var.environment}-${element(var.buckets_external_list, count.index)}/"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  replication_configuration {
    role = "${aws_iam_role.replication.arn}"

    rules {
      id     = "${var.environment}-${element(var.buckets_external_list, count.index)}"
      status = "Enabled"

      destination {
        bucket        = "${aws_s3_bucket.destination_external.*.arn[count.index]}"
        storage_class = "STANDARD"
      }
    }
  }
}

resource "aws_s3_bucket_notification" "this_external" {
  count  = "${length(var.buckets_external_list)}"
  bucket = "${aws_s3_bucket.this_external.*.id[count.index]}"

  topic {
    topic_arn     = "${var.sns_topic_arn}"
    events        = ["s3:ObjectRemoved:*", "s3:ObjectRestore:Post", "s3:ObjectRestore:Completed"]
    filter_prefix = "${aws_s3_bucket.this_external.*.id[count.index]}/"
    id            = "delete-restore"
  }
}

data "aws_iam_policy_document" "common_s3_policy" {
  count = "${length(var.buckets_common_list)}"

  statement {
    actions = ["s3:*"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    resources = [
      "arn:aws:s3:::${var.environment}-${element(var.buckets_common_list, count.index)}",
      "arn:aws:s3:::${var.environment}-${element(var.buckets_common_list, count.index)}/*",
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
      "arn:aws:s3:::${var.environment}-${element(var.buckets_common_list, count.index)}",
      "arn:aws:s3:::${var.environment}-${element(var.buckets_common_list, count.index)}/*",
    ]

    condition {
      test     = "StringNotLike"
      variable = "aws:SourceVpce"
      values   = ["${var.vpc_endpoints}"]
    }
  }
}

data "aws_iam_policy_document" "external_s3_policy" {
  count = "${length(var.buckets_external_list)}"

  statement {
    actions = ["s3:*"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    resources = [
      "arn:aws:s3:::${var.environment}-${element(var.buckets_external_list, count.index)}",
      "arn:aws:s3:::${var.environment}-${element(var.buckets_external_list, count.index)}/*",
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
      "arn:aws:s3:::${var.environment}-${element(var.buckets_external_list, count.index)}",
      "arn:aws:s3:::${var.environment}-${element(var.buckets_external_list, count.index)}/*",
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

resource "aws_s3_bucket_policy" "this_common" {
  count      = "${length(var.buckets_common_list)}"
  bucket     = "${var.environment}-${element(var.buckets_common_list, count.index)}"
  policy     = "${data.aws_iam_policy_document.common_s3_policy.*.json[count.index]}"
  depends_on = ["aws_s3_bucket.this_common", "aws_s3_bucket_notification.this_common"]
}

resource "aws_s3_bucket_policy" "this_external" {
  count      = "${length(var.buckets_external_list)}"
  bucket     = "${var.environment}-${element(var.buckets_external_list, count.index)}"
  policy     = "${data.aws_iam_policy_document.external_s3_policy.*.json[count.index]}"
  depends_on = ["aws_s3_bucket.this_external", "aws_s3_bucket_notification.this_external"]
}
