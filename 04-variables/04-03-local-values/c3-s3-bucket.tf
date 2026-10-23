# Sin locals, la misma expresion se repite (y se repite mas con cada recurso nuevo):
/*
resource "aws_s3_bucket" "mys3bucket" {
  bucket = "${var.app_name}-${var.environment_name}-bucket"
  tags = {
    Name        = "${var.app_name}-${var.environment_name}-bucket"
    Environment = var.environment_name
  }
}
*/

# Define Local Values: se calculan UNA vez y se reusan con local.<nombre>
locals {
  bucket-name = "${var.app_name}-${var.environment_name}-bucket" # Complex expression
  common_tags = {
    App         = var.app_name
    Environment = var.environment_name
    ManagedBy   = "terraform"
  }
}

# Create S3 Bucket - with Input Variables & Local Values
resource "aws_s3_bucket" "mys3bucket" {
  bucket = local.bucket-name
  # merge(): combina los tags comunes con uno propio de este recurso
  tags = merge(local.common_tags, { Name = local.bucket-name })
}

output "bucket_name" {
  value = aws_s3_bucket.mys3bucket.bucket
}
