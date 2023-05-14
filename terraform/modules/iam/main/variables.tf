variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "role_common_list" {
  description = "List of common roles"
  type        = "list"
}

variable "role_restricted_list" {
  description = "List of restricted roles"
  type        = "list"
}

variable "postgres_roles" {
  description = "Lost of roles to access RDS"
  type        = "list"
}

variable "redshift_roles" {
  description = "Lost of roles to access Redshift"
  type        = "list"
}

variable "main_account_id" {
  description = "Main account ID"
}

variable "shared_account_id" {
  description = "Shared account ID"
}

variable "vpc_endpoints" {
  description = "List of vpc endpoints to allow access from"
  type        = "list"
}

variable "allowed_ips" {
  description = "List of whitelisted IPs"
  type        = "list"
}

variable "buckets_common_list" {
  description = "List of buckets to access from VPC only"
  type        = "list"
}

variable "buckets_external_list" {
  description = "List of buckets to access from VPC and External whitelisted IP"
  type        = "list"
}

variable "access_log_bucket" {
  description = "S3 bucket to store access logs"
}

variable "sns_topic_arn" {
  description = "SNS topic to send delete/restore events"
}

variable "environment" {
  description = "Name of the global environment (C3, C4...)"
}

variable "replication_region" {
  description = "Target region for S3 replication"
}

variable "dr_access_logs" {
  description = "DR access logs bucket"
}

variable "dr_sns_topic" {
  description = "DR SNS Topic for notifications"
}
