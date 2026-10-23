# Reemplaza los pasos "manuales en consola" del lab (crear bucket + tabla).
# Este directorio usa state LOCAL a proposito: el backend no puede guardarse
# a si mismo (problema del huevo y la gallina).

# S3 Bucket para el state
resource "aws_s3_bucket" "state" {
  bucket        = var.state_bucket_name
  force_destroy = true # solo para laboratorio: permite borrar el bucket con versiones adentro
}

# Versionado: cada apply genera una NUEVA version del tfstate -> se puede volver atras
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Cifrado en reposo (el state puede tener passwords, ver 04-01 v4)
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Nada publico
resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB Table para State Locking: partition key "LockID" (String)
resource "aws_dynamodb_table" "lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

output "state_bucket" {
  value = aws_s3_bucket.state.bucket
}

output "lock_table" {
  value = aws_dynamodb_table.lock.name
}
