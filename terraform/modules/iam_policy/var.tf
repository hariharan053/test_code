#variable "s3_policy_name" {
#}
#
#variable "sm_policy_name" {
#}
#
#variable "glue_policy_name" {
#}
#
#variable "sqs_policy_name" {
#}
#
#variable "s3_sm_sqs_glue_policy_name" {
#}
#
variable "environment" {}
variable "bucket_name" {type = list(string)}
variable "sqs_name" {type = list(string)}
variable "sns_name" {type = list(string)}
variable "sm_name"  {type = list(string)}
variable "tf_bucket" {}