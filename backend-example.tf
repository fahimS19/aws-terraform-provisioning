# terraform {
#   backend "s3" {
#     bucket       = "AN-EXISTING-TERRAFORM-STATE-BUCKET"
#     key          = "terraform-assignment/terraform.tfstate"
#     region       = "us-east-1"
#     encrypt      = true
#     use_lockfile = true
#   }
# }

//How the Design Works

# Centralized State (S3): Instead of storing the terraform.tfstate file locally on a single machine, 
# S3 hosts it centrally. This creates a single source of truth, ensuring all team members and CI/CD pipelines are 
# working from the exact same infrastructure state.

# State Locking (DynamoDB): A DynamoDB table acts as a traffic controller. When a terraform apply or plan runs, it places
#  a lock in the table. If a second run starts simultaneously, it is blocked until the first finishes, 
#  entirely eliminating the risk of concurrent modifications corrupting the state file.

# Security & Safety: Enabling encrypt = true ensures the state file (which often contains sensitive plaintext outputs)
# is encrypted at rest.
