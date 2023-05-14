data "aws_caller_identity" "current" {
}
data "aws_iam_policy_document" "sqs" {
  statement {
    sid = "VisualEditor0"
    effect = "Allow"

    actions = [
          "sqs:ReceiveMessage",
          "sqs:SendMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
    ]

    resources = [
    for acct in var.sqs_name:
      "arn:aws:sqs:us-east-1:${data.aws_caller_identity.current.account_id}:${acct}"
    ]
  }
}

resource "aws_iam_policy" "sqs_policy" {
  #name        = var.sqs_policy_name
  name        = "${var.environment}-sqs-policy"
  path        = "/"
  description = "Policy for SQS access"
  policy = data.aws_iam_policy_document.sqs.json
}

data "aws_iam_policy_document" "s3" {
  statement {
    sid = "VisualEditor0"
    effect = "Allow"

    actions = [
          "s3:GetObjectAcl",
          "s3:GetObject",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:ListBucket",
          "s3:GetBucketVersioning",
          "s3:GetBucketPolicy",
          "s3:GetBucketPublicAccessBlock"
    ]

    resources = [
    for acct in var.bucket_name:
      "arn:aws:s3:::${acct}*"
    ]
  }
}

resource "aws_iam_policy" "s3_policy" {
  #name        = var.sqs_policy_name
  name        = "${var.environment}-s3-policy"
  path        = "/"
  description = "Policy for SQS access"
  policy = data.aws_iam_policy_document.s3.json
}


data "aws_iam_policy_document" "sm" {
  statement {
    sid = "VisualEditor0"
    effect = "Allow"

    actions = [
         "secretsmanager:GetSecretValue",
         "secretsmanager:DescribeSecret"
    ]

    resources = [
    for acct in var.sm_name:
        "arn:aws:secretsmanager:us-east-1:${data.aws_caller_identity.current.account_id}:secret:${acct}-*"
    ]
  }
}

resource "aws_iam_policy" "sm_policy" {
  #name        = var.sm_policy_name
  name        = "${var.environment}secret-manager-policy"
  path        = "/"
  description = "Policy for secret manager access"

  policy = data.aws_iam_policy_document.sm.json

}

resource "aws_iam_policy" "glue_policy" {
  #name        = var.glue_policy_name
  name        = "${var.environment}-glue-policy"
  path        = "/"
  description = "Policy for Glue access"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "glue:CreateDatabase",
                "glue:DeleteDatabase",
                "glue:GetDatabase",
                "glue:GetDatabases",
                "glue:UpdateDatabase",
                "glue:CreateTable",
                "glue:DeleteTable",
                "glue:BatchDeleteTable",
                "glue:UpdateTable",
                "glue:GetTable",
                "glue:GetTables",
                "glue:BatchCreatePartition",
                "glue:CreatePartition",
                "glue:DeletePartition",
                "glue:BatchDeletePartition",
                "glue:UpdatePartition",
                "glue:GetPartition",
                "glue:GetPartitions",
                "glue:BatchGetPartition",
                "lakeformation:GetDataAccess"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF

}



data "aws_iam_policy_document" "all-policy" {
  statement {
    sid = "VisualEditor0"
    effect = "Allow"

    actions = [
                "s3:GetObjectAcl",
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:ListBucket",
                "s3:GetBucketVersioning",
                "s3:GetBucketPolicy",
                "s3:GetBucketPublicAccessBlock"
    ]

    resources = [
    for acct in var.bucket_name:
      "arn:aws:s3:::${acct}/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
                "s3:GetObjectAcl",
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:ListBucket",
                "s3:GetBucketVersioning",
                "s3:GetBucketPolicy",
                "s3:GetBucketPublicAccessBlock"
    ]

    resources = [
    for acct in var.bucket_name:
      "arn:aws:s3:::${acct}"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
                "s3:GetObjectAcl",
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:ListBucket",
                "s3:GetBucketVersioning",
                "s3:GetBucketPolicy",
                "s3:GetBucketPublicAccessBlock"
    ]

    resources = [
      "arn:aws:s3:::${var.tf_bucket}/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
                "s3:GetObjectAcl",
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:ListBucket",
                "s3:GetBucketVersioning",
                "s3:GetBucketPolicy",
                "s3:GetBucketPublicAccessBlock"
    ]

    resources = [
      "arn:aws:s3:::${var.tf_bucket}"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
         "secretsmanager:GetSecretValue",
         "secretsmanager:DescribeSecret"
    ]

    resources = [
    for acct in var.sm_name:
        "arn:aws:secretsmanager:us-east-1:${data.aws_caller_identity.current.account_id}:secret:${acct}-*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
                "glue:CreateDatabase",
                "glue:DeleteDatabase",
                "glue:GetDatabase",
                "glue:GetDatabases",
                "glue:UpdateDatabase",
                "glue:CreateTable",
                "glue:DeleteTable",
                "glue:BatchDeleteTable",
                "glue:UpdateTable",
                "glue:GetTable",
                "glue:GetTables",
                "glue:BatchCreatePartition",
                "glue:CreatePartition",
                "glue:DeletePartition",
                "glue:BatchDeletePartition",
                "glue:UpdatePartition",
                "glue:GetPartition",
                "glue:GetPartitions",
                "glue:BatchGetPartition",
                "lakeformation:GetDataAccess"
    ]

    resources =  ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
          "sqs:ReceiveMessage",
          "sqs:SendMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
    ]

    resources = [
    for acct in var.sqs_name:
      "arn:aws:sqs:us-east-1:${data.aws_caller_identity.current.account_id}:${acct}"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
        "sns:GetTopicAttributes",
    ]

    resources = [
    for acct in var.sns_name:
      "arn:aws:sns:us-east-1:${data.aws_caller_identity.current.account_id}:${acct}"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
        "ssm:GetParameters",
    ]

    resources = [
        "arn:aws:ssm:us-east-1:${data.aws_caller_identity.current.account_id}:parameter/subnet_list",
        "arn:aws:ssm:us-east-1:${data.aws_caller_identity.current.account_id}:parameter/sg_name"
    ]
  }
}

resource "aws_iam_policy" "s3_sm_sqs_glue_policy" {
  #name        = var.s3_sm_sqs_glue_policy_name
  name        = "${var.environment}-all-policy"
  path        = "/"
  description = "Policy for S3,SQS,Glue,SM,SNS access"

  policy = data.aws_iam_policy_document.all-policy.json
}

resource "aws_iam_role" "glue-access" {
  name = "${var.environment}-glue_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY


  tags = {
    role = "glue_role"
  }
}

resource "aws_iam_role_policy_attachment" "AWSGlueServiceNotebookRole" {
  role       = aws_iam_role.glue-access.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceNotebookRole"
}

resource "aws_iam_role_policy_attachment" "AWSGlueConsoleSageMakerNotebookFullAccess" {
  role       = aws_iam_role.glue-access.name
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleSageMakerNotebookFullAccess"
}

resource "aws_iam_role_policy_attachment" "AWSGlueServiceRole" {
  role       = aws_iam_role.glue-access.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "AWSBatchFullAccess" {
  role       = aws_iam_role.glue-access.name
  policy_arn = "arn:aws:iam::aws:policy/AWSBatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "AmazonRedshiftFullAccess" {
  role       = aws_iam_role.glue-access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}

resource "aws_iam_role_policy_attachment" "SNS_SQS_SM_S3" {
  role       = aws_iam_role.glue-access.name
  policy_arn = aws_iam_policy.s3_sm_sqs_glue_policy.arn
}