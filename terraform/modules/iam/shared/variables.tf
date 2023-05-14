data "aws_caller_identity" "current" {}

variable "role_restricted_list" {
  description = "List of restricted roles"
  type        = "list"
}

variable "role_common_list" {
  description = "List of common roles to assume"
  type        = "list"
}

variable "main_account_id" {
  description = "ID of the main account"
}

variable "shared_account_id" {
  description = "ID of the shared account"
}

variable "environment" {
  description = "Global environment name"
}
