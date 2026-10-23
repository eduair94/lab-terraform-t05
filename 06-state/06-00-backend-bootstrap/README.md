# 06-00 · Bootstrap del backend (bucket S3 + tabla DynamoDB)

> **En una frase:** antes de guardar el state en S3 hay que crear el bucket y la tabla de lock. El lab original lo hace con clics en la consola; acá lo hacemos con Terraform.

## 🧠 Lo esencial
| Recurso | Para qué |
|---|---|
| `aws_s3_bucket` | Guarda los `terraform.tfstate` |
| `aws_s3_bucket_versioning` | Cada `apply` crea una **versión nueva** del state, así puedes volver atrás si algo se rompe |
| `aws_s3_bucket_server_side_encryption_configuration` | Cifrado en reposo (el state puede tener passwords) |
| `aws_s3_bucket_public_access_block` | Bloquea todo acceso público |
| `aws_dynamodb_table` (`hash_key = "LockID"`) | Tabla para el **lock**: un solo `apply` a la vez |

🥚🐔 **Huevo y gallina:** este directorio usa state **local**, porque un backend no puede guardar el state de los recursos que lo crean.

## ▶️ Ejecutar (sin AWS)
```bash
terraform init
terraform apply -auto-approve
```
```text
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
lock_table   = "terraform-dev-state-table"
state_bucket = "terraform-devopslab-state"
```
➡️ Déjalo creado mientras haces 06-01, 06-02 y 07-v2. Al final: `terraform destroy -auto-approve`.

## 💡 Para recordar
- Los nombres de bucket son **únicos en todo AWS** y van **en minúsculas** (el lab original usa `terraform-DevOpsLab`, que AWS rechaza por las mayúsculas). En AWS real, agrega un sufijo propio, por ejemplo `terraform-devopslab-state-tu-nombre`.
- Con Terraform ≥ 1.10 la tabla DynamoDB es opcional: `use_lockfile = true` hace el lock en el propio S3 (ver 06-01).

Siguiente → [06-01 Remote State & Locking](../06-01-remote-state-locking/)
