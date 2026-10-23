# 04-03 · Local Values (`locals`)

> **En una frase:** un `local` le pone nombre a una expresión para escribirla **una vez** y usarla en varios lugares (principio DRY: *Don't Repeat Yourself*).

## 🧠 Variable vs. Local

| | `variable` | `locals` |
|---|---|---|
| ¿Quién define el valor? | Quien **usa** el código (tfvars, CLI...) | El **código** mismo |
| ¿Se puede cambiar desde afuera? | ✅ Sí | ❌ No |
| ¿Puede usar otras variables o funciones? | ❌ No (`default` debe ser fijo) | ✅ Sí |
| Se usa con | `var.x` | `local.x` |

```hcl
locals {
  bucket-name = "${var.app_name}-${var.environment_name}-bucket"
  common_tags = { App = var.app_name, Environment = var.environment_name, ManagedBy = "terraform" }
}

resource "aws_s3_bucket" "mys3bucket" {
  bucket = local.bucket-name
  tags   = merge(local.common_tags, { Name = local.bucket-name })   # tags comunes + uno propio
}
```

## ▶️ Ejecutar (sin AWS)
```bash
terraform init && terraform plan
terraform apply -auto-approve
terraform state show aws_s3_bucket.mys3bucket
terraform destroy -auto-approve
```
Los valores salen de `terraform.tfvars` (`app_name = "myapp"`, `environment_name = "dev"`). En el lab original no había defaults y Terraform los pedía.

## 👀 Salida real (moto)
```text
aws_s3_bucket.mys3bucket: Creation complete after 1s [id=myapp-dev-bucket]
bucket_name = "myapp-dev-bucket"
    tags = {
        "App"         = "myapp"
        "Environment" = "dev"
        "ManagedBy"   = "terraform"
        "Name"        = "myapp-dev-bucket"
    }
```

## 💡 Para recordar
- Úsalo cuando un valor se **repite** o una expresión es **larga**. Si se usa una sola vez, no hace falta.
- Patrón muy común: `local.common_tags` + `merge()` para etiquetar todos los recursos igual.
- ⭐ **Extra:** se agregó `common_tags` con `merge()` (no estaba en el lab original). Es el uso más común de `locals` en proyectos reales.

📚 [Locals](https://developer.hashicorp.com/terraform/language/values/locals) · Siguiente → [05 Data Sources](../../05-datasources/)
