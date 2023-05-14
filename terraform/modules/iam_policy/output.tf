output "s3_policy_arn" {
  value = aws_iam_policy.s3_policy.arn
}

output "sm_policy_arn" {
  value = aws_iam_policy.sm_policy.arn
}

output "glue_policy_arn" {
  value = aws_iam_policy.glue_policy.arn
}

output "sqs_policy_arn" {
  value = aws_iam_policy.sqs_policy.arn
}


output "glue_role_arn" {
  value = aws_iam_role.glue-access.arn
}

