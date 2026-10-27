
variable "environment" {
  type        = string
  description = "Deployment environment: dev, staging, or prod."

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "company" {
  type        = string
  description = "Company prefix for resource names."

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.company))
    error_message = "Company must use lowercase letters, numbers, and hyphens."
  }
}

variable "project" {
  type        = string
  description = "Project name used in resource names."

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project))
    error_message = "Project must use lowercase letters, numbers, and hyphens."
  }
}

variable "aws_region" {
  type        = string
  description = "AWS deployment region."

  validation {
    condition = contains(
      ["us-east-1", "us-east-2", "us-west-2"],
      var.aws_region
    )
    error_message = "Region must be us-east-1, us-east-2, or us-west-2."
  }
}

variable "tags" {
  type        = map(string)
  description = "Additional resource tags."
  default     = {}
}

variable "enable_versioning" {
  type    = bool
  default = false
}

variable "enable_dynamodb" {
  type    = bool
  default = true
}

variable "enable_iam_role" {
  type    = bool
  default = true
}

variable "enable_ssm_parameters" {
  type    = bool
  default = true
}

variable "enable_cloudwatch_logs" {
  type    = bool
  default = true
}

variable "enable_lifecycle_rule" {
  type    = bool
  default = true
}

variable "enable_ec2_test_instance" {
  type    = bool
  default = false

  validation {
    condition = !(
      var.environment == "prod" &&
      var.enable_ec2_test_instance
    )
    error_message = "EC2 must never be enabled in prod."
  }
}

variable "prevent_destroy" {
  type        = bool
  description = "Indicates whether resource deletion should be prevented."
  default     = false
}

variable "lifecycle_expiration_days" {
  type        = number
  description = "Days before lifecycle expiration."

  validation {
    condition = (
      var.lifecycle_expiration_days >= 1 &&
      var.lifecycle_expiration_days == floor(var.lifecycle_expiration_days)
    )
    error_message = "Expiration days must be a positive integer."
  }
}

variable "ssm_parameters" {
  type        = map(string)
  description = "SSM String parameters to create."
  default     = {}
}

variable "log_groups" {
  type        = map(number)
  description = "CloudWatch log group names and retention days."
  default     = {}

  validation {
    condition = alltrue([
      for days in values(var.log_groups) :
      contains([1, 3, 5, 7, 14, 30, 60, 90], days)
    ])
    error_message = "Log retention must use an allowed retention period."
  }
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to access the security group."
  default     = []
}
