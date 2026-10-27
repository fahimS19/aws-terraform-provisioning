# terraform {
#   backend "s3" {
#     bucket       = "YOUR-EXISTING-TERRAFORM-STATE-BUCKET"
#     key          = "terraform-assignment/terraform.tfstate"
#     region       = "us-east-1"
#     encrypt      = true
#     use_lockfile = true
#   }
# }
