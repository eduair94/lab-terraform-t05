# 06-01 · Remote State (S3) + State Locking

> **En una frase:** el state se guarda en un bucket S3 compartido (no en tu laptop), con **versionado** para recuperarlo y **lock** para que dos personas no hagan `apply` a la vez.

## 🧠 Lo esencial

| Problema del state local | Solución |
|---|---|
| Si pierdes la laptop, pierdes el state | Bucket S3 (durable) |
| El equipo no comparte la "memoria" | Todos leen y escriben el mismo state |
| Un error corrompe el state | **Versionado** del bucket |
| Dos `apply` simultáneos corrompen el state | **Lock** (DynamoDB o `use_lockfile`) |

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-devopslab-state"
    key            = "dev/terraform.tfstate"      # "ruta" del archivo dentro del bucket
    region         = "us-east-1"
    dynamodb_table = "terraform-dev-state-table"  # lock clásico
    # use_lockfile = true                         # lock moderno (TF >= 1.10), sin DynamoDB
  }
}
```
> ❗ El bloque `backend` **no acepta variables**. Los valores que cambian según el entorno se pasan con `-backend-config` (*partial configuration*). Así funciona `backend-moto.hcl`.

## ▶️ Ejecutar (sin AWS)
Requisito: [06-00](../06-00-backend-bootstrap/) aplicado.
```bash
terraform init -backend-config=backend-moto.hcl     # AWS real: terraform init
terraform apply -auto-approve
ls -a                                                # ¡no hay terraform.tfstate local!
aws --endpoint-url http://localhost:5000 s3 ls s3://terraform-devopslab-state --recursive
```
**Versionado:** en `c2-variables.tf` cambia el `default` a `t2.small` y aplica otra vez:
```bash
terraform apply -auto-approve
aws --endpoint-url http://localhost:5000 s3api list-object-versions \
    --bucket terraform-devopslab-state --prefix dev/
```

## 👀 Salida real (moto)
```text
Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

$ aws s3 ls ... --recursive
2026-10-22 22:35:49      12241 dev/terraform.tfstate

      ~ instance_type = "t2.micro" -> "t2.small"
Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

$ aws s3api list-object-versions ...
|  081ad99d-cf1b-...  |  True  |  12233 |  2026-10-23T01:36:34Z |   <- versión actual
|  87d2adb6-4cb5-...  |  False |  12241 |  2026-10-23T01:35:49Z |   <- versión anterior (recuperable)

$ aws dynamodb scan --table-name terraform-dev-state-table
terraform-devopslab-state/dev/terraform.tfstate-md5     <- checksum que guarda el backend
```

### 🔒 ¿Y el lock? (lo vemos en acción en [06-02](../06-02-state-commands/))
Si dos procesos corren a la vez, el segundo falla:
```text
Error: Error acquiring the state lock
ConditionalCheckFailedException: The conditional request failed
Lock Info:
  ID:        6881b34b-d944-044b-6c8a-de22fd218081
  Path:      terraform-devopslab-state/statecommands/terraform.tfstate
  Operation: OperationTypeApply
```
Con `use_lockfile = true` (probado con moto) el lock es un archivo `terraform.tfstate.tflock` en el bucket y el error es `S3: PutObject ... StatusCode: 412`.

## 💡 Para recordar
- Terraform 1.11+ muestra `Warning: Deprecated Parameter "dynamodb_table"`. Funciona igual, pero en proyectos nuevos se usa `use_lockfile = true`.
- Cambiar el backend → `terraform init -reconfigure` (empezar de cero) o `-migrate-state` (copiar el state existente).
- Limpieza: `terraform destroy -auto-approve && rm -rf .terraform*`.

📚 [S3 backend](https://developer.hashicorp.com/terraform/language/backend/s3) · Siguiente → [06-02 State Commands](../06-02-state-commands/)
