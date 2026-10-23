# =============================================================================
# moto_override.tf  ->  "AWS falso" para practicar SIN cuenta ni creditos
# -----------------------------------------------------------------------------
# Terraform mezcla automaticamente cualquier archivo *_override.tf con el
# resto de la configuracion. Este archivo redirige el provider "aws" a
# moto (http://localhost:5000), un simulador local de la API de AWS.
#
#   Usar AWS real  ->  borrar este archivo (y configurar tus credenciales).
# =============================================================================
provider "aws" {
  access_key                  = "testing"
  secret_key                  = "testing"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    dynamodb = "http://localhost:5000"
    ec2      = "http://localhost:5000"
    iam      = "http://localhost:5000"
    rds      = "http://localhost:5000"
    s3       = "http://localhost:5000"
    sts      = "http://localhost:5000"
  }
}
