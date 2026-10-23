# aws-s3-static-website-bucket

Modulo para hostear un sitio estatico en S3.

## Uso
```hcl
module "website_s3_bucket" {
  source      = "./modules/aws-s3-static-website-bucket"
  bucket_name = "mi-bucket-unico"
  tags        = { Environment = "dev" }
}
```

## Inputs
| Nombre | Tipo | Default | Descripcion |
|---|---|---|---|
| `bucket_name` | string | - | Nombre unico global del bucket |
| `tags` | map(string) | `{}` | Tags del bucket |

## Outputs
`arn`, `name`, `domain`, `endpoint`
