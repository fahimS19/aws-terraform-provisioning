
locals {
  env_short = {
    dev     = "dev"
    staging = "stg"
    prod    = "prd"
  }

  region_short = {
    us-east-1 = "use1"
    us-east-2 = "use2"
    us-west-2 = "usw2"
  }

  name_prefix = "${var.company}-${var.project}-${local.env_short[var.environment]}-fahim30246"

  region_suffix = local.region_short[var.aws_region]

  common_tags = merge(
    {
      Company     = var.company
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}
