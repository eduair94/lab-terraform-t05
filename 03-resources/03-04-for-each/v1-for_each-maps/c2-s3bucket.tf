# Create S3 Bucket per environment with for_each and maps
resource "aws_s3_bucket" "mys3bucket" {

  for_each = {
    dev  = "my-dapp-bucket"
    qa   = "my-qapp-bucket"
    stag = "my-sapp-bucket"
    prod = "my-papp-bucket"
  }

  # each.key = dev | qa | stag | prod      each.value = my-dapp-bucket | ...
  bucket = "${each.key}-${each.value}"
  # Nota: "acl = private" se quito. En aws v4+ los buckets son privados por defecto
  # y el ACL se maneja con el recurso aparte aws_s3_bucket_acl.

  tags = {
    eachvalue   = each.value
    Environment = each.key
    bucketname  = "${each.key}-${each.value}"
  }
}

output "bucket_names" {
  # for expression sobre un recurso con for_each -> map clave => nombre
  value = { for k, b in aws_s3_bucket.mys3bucket : k => b.bucket }
}
