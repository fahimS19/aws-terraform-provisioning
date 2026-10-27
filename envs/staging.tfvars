
environment = "staging"
company     = "bjit"
project     = "tfassign"
aws_region  = "us-east-1"

enable_versioning         = true
enable_dynamodb           = true
enable_iam_role           = true
enable_ssm_parameters     = true
enable_cloudwatch_logs    = true
enable_lifecycle_rule     = true
enable_ec2_test_instance  = false
prevent_destroy           = false
lifecycle_expiration_days = 30

ssm_parameters = {
  app_name  = "terraform-training-staging"
  log_level = "INFO"
}

log_groups = {
  app    = 14
  worker = 14
}

allowed_cidr_blocks = []

tags = {
  Owner      = "fahim30246"
  CostCenter = "training"
  ManagedBy  = "Terraform"
}
