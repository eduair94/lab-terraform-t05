# Call our Custom Terraform Module which we built earlier
module "website_s3_bucket" {
  source      = "./modules/aws-s3-static-website-bucket" # modulo LOCAL
  bucket_name = var.my_s3_bucket
  tags        = var.my_s3_tags
}

# Reutilizacion: el mismo modulo, otra vez, con otros parametros (una linea por sitio)
module "website_s3_bucket_qa" {
  source      = "./modules/aws-s3-static-website-bucket"
  bucket_name = "${var.my_s3_bucket}-qa"
  tags        = merge(var.my_s3_tags, { Environment = "qa" })
}
