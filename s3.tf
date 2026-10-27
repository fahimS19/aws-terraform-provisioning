
resource "aws_s3_bucket" "app" {
  bucket = "${local.name_prefix}-app-bucket-${local.region_suffix}"

  tags = local.common_tags
}


resource "aws_s3_bucket_ownership_controls" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.app.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_versioning" "app" {
  bucket = aws_s3_bucket.app.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "app" {
  count  = var.enable_lifecycle_rule ? 1 : 0
  bucket = aws_s3_bucket.app.id

  rule {
    id     = "expire-old-objects"
    status = "Enabled"

    filter {
      prefix = ""
    }

    dynamic "expiration" {
      for_each = [var.lifecycle_expiration_days]

      content {
        days = expiration.value
      }
    }
  }
}
