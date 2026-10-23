# 03-04 · Meta-argument `for_each`

> **En una frase:** como `count`, pero cada copia se identifica por una **clave** (`"dev"`, `"Jack"`) y no por una posición. Por eso agregar o quitar elementos no afecta a los demás.

## 🧠 Lo esencial

| | Acepta | Dentro del bloque | Dirección en el state |
|---|---|---|---|
| **map** | `{ dev = "x", qa = "y" }` | `each.key` = `dev`, `each.value` = `x` | `aws_s3_bucket.b["dev"]` |
| **set** | `toset(["Jack","Dave"])` | `each.key` = `each.value` = `Jack` | `aws_iam_user.u["Jack"]` |

> ❗ `for_each` **no acepta listas**: conviértelas con `toset()`.

| Carpeta | Qué crea |
|---|---|
| [v1-for_each-maps](v1-for_each-maps/) | 4 buckets S3: `dev-my-dapp-bucket`, `qa-...`, `stag-...`, `prod-...` |
| [v2-for_each-toset](v2-for_each-toset/) | 4 usuarios IAM: Jack, James, Madhu, Dave |
| [v3-count-vs-for_each](v3-count-vs-for_each/) | ⭐ **Extra**: experimento local (sin AWS) que muestra por qué conviene `for_each` |

## ▶️ Ejecutar (sin AWS)
```bash
cd v1-for_each-maps     # o v2-for_each-toset
terraform init && terraform plan
terraform apply -auto-approve
terraform destroy -auto-approve
```

## 👀 Salida real (moto)
```text
# v1 (map)
aws_s3_bucket.mys3bucket["qa"]: Creation complete after 5s [id=qa-my-qapp-bucket]
bucket_names = {
  "dev"  = "dev-my-dapp-bucket"
  "prod" = "prod-my-papp-bucket"
  ...
# v2 (set)
aws_iam_user.myuser["Jack"]: Creation complete after 2s [id=Jack]
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

## 🧪 Experimento v3: quitar "beto" del medio de `["ana","beto","carla"]`
```bash
cd v3-count-vs-for_each
terraform init && terraform apply -auto-approve
terraform plan -var='users=["ana","carla"]'
```
```text
  # terraform_data.with_count[1] will be updated in-place
      ~ input  = "beto" -> "carla"                    <- ¡se corrió de posición!
  # terraform_data.with_count[2] will be destroyed
  # (because index [2] is out of range for count)     <- ¡borra a carla!
  # terraform_data.with_for_each["beto"] will be destroyed   <- solo toca a beto ✅
Plan: 0 to add, 1 to change, 2 to destroy.
```
Con `count`, un cambio en el medio de la lista afecta a los elementos que siguen. Con `for_each`, solo cambia el elemento que quitaste. Si esos recursos fueran bases de datos, con `count` perderías datos.

## 💡 Para recordar
- Regla práctica: **copias idénticas → `count`**, **cosas con identidad propia → `for_each`**.
- 🔄 **Cambio vs. el lab original:** se quitó `acl = "private"` de `aws_s3_bucket` (deprecado en AWS v4+). Los buckets ya son privados por defecto.

📚 [for_each](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each) · Siguiente → [03-05 lifecycle](../03-05-lifecycle/)
