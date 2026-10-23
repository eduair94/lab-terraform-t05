# Create S3 Bucket Resource
# (aws v4+) El viejo bloque unico con acl/policy/website se divide en recursos separados.
resource "aws_s3_bucket" "s3_bucket" {
  bucket        = var.bucket_name
  tags          = var.tags
  force_destroy = true
}

# Static website hosting
resource "aws_s3_bucket_website_configuration" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

# Destildar "Block all public access"
resource "aws_s3_bucket_public_access_block" "s3_bucket" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Public Read policy (jsonencode es mas seguro que un heredoc: valida la sintaxis)
resource "aws_s3_bucket_policy" "s3_bucket" {
  bucket     = aws_s3_bucket.s3_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.s3_bucket] # sin esto AWS rechaza la policy
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = ["s3:GetObject"]
      Resource  = ["${aws_s3_bucket.s3_bucket.arn}/*"]
    }]
  })
}
