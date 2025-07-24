# Get the AWS account ID
data "aws_caller_identity" "current" {}

locals {
  # # S3 variables
  # state_bucket_name      = "${var.app_name}-${var.env_name}-state-bucket"

  # # Dynamo DB
  # dynamodb_table_name = "${var.app_name}-${var.env_name}-dynamodb-table-terraform-state"

  # ACM, ALB
  domain_url = "${var.env_name != "prod" ? "pcdc-${var.env_name}" : ""}.${var.base_domain_url}"

}