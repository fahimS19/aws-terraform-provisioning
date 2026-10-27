
output "s3_bucket_name" {
  description = "Application S3 bucket name."
  value       = aws_s3_bucket.app.bucket
}

output "s3_bucket_arn" {
  description = "Application S3 bucket ARN."
  value       = aws_s3_bucket.app.arn
}

output "dynamodb_table_name" {
  description = "DynamoDB table name, if enabled."
  value       = var.enable_dynamodb ? aws_dynamodb_table.config[0].name : null
}

output "iam_role_arn" {
  description = "Application IAM role ARN, if enabled."
  value       = var.enable_iam_role ? aws_iam_role.app[0].arn : null
}

output "ssm_parameter_names" {
  description = "Names of created SSM parameters."
  value       = keys(aws_ssm_parameter.app)
}

output "cloudwatch_log_group_names" {
  description = "Names of created CloudWatch log groups."
  value       = keys(aws_cloudwatch_log_group.app)
}

output "security_group_id" {
  description = "Application security group ID."
  value       = aws_security_group.app.id
}

output "ec2_instance_id" {
  description = "EC2 instance ID, if enabled."
  value       = var.enable_ec2_test_instance ? aws_instance.test[0].id : null
}
