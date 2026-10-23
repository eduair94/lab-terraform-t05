# =============================================================================
# backend-moto.hcl  ->  "Partial backend configuration" para usar moto
# -----------------------------------------------------------------------------
#   terraform init -backend-config=backend-moto.hcl     (moto, sin AWS)
#   terraform init                                       (AWS real)
# Estos valores se MEZCLAN con el bloque backend "s3" de c1-versions.tf.
# =============================================================================
access_key                  = "testing"
secret_key                  = "testing"
use_path_style              = true
skip_credentials_validation = true
skip_requesting_account_id  = true
skip_metadata_api_check     = true
endpoints = {
  s3       = "http://localhost:5000"
  dynamodb = "http://localhost:5000"
  sts      = "http://localhost:5000"
}
