# 03-05 · Meta-argument `lifecycle`

> **En una frase:** `lifecycle` cambia cómo Terraform crea, reemplaza o destruye un recurso.

## 🧠 Lo esencial

| Argumento | Para qué | Ejemplo real |
|---|---|---|
| `create_before_destroy = true` | Al reemplazar: **primero crea** el nuevo y **después borra** el viejo. | Evitar downtime en un servidor web. |
| `prevent_destroy = true` | Hace fallar cualquier plan que destruya el recurso. | Proteger la base de datos de producción. |
| `ignore_changes = [tags]` | Terraform ignora los cambios en esos atributos. | Tags que agrega otra herramienta o una persona. |

## ▶️ Ejecutar (sin AWS) y 👀 salida real

### v1 · create_before_destroy ([carpeta](v1-create_before_destroy/))
1. `terraform init && terraform apply -auto-approve`
2. Cambia la AZ a `us-east-1b` → `apply`. **Orden por defecto:**
```text
aws_instance.web: Destroying...          <- 1) borra el viejo (¡downtime!)
aws_instance.web: Destruction complete
aws_instance.web: Creating...            <- 2) crea el nuevo
```
3. Descomenta el bloque `lifecycle`, vuelve la AZ a `us-east-1a` → `apply`:
```text
aws_instance.web: Creating...                          <- 1) crea el nuevo
aws_instance.web: Creation complete
aws_instance.web (deposed object c0eb27fa): Destroying...  <- 2) borra el viejo ("deposed")
```

### v2 · prevent_destroy ([carpeta](v2-prevent_destroy/))
```bash
terraform apply -auto-approve
terraform destroy -auto-approve
```
```text
Error: Instance cannot be destroyed
Resource aws_instance.web has lifecycle.prevent_destroy set, but the plan
calls for this resource to be destroyed.
```
Para destruirlo, cambia `prevent_destroy` a `false` o comenta el bloque, y ejecuta `destroy` otra vez.
> ⚠️ Si **borras el bloque `resource` completo**, la protección se va con él y Terraform lo destruye.

### v3 · ignore_changes ([carpeta](v3-ignore_changes/))
Simulamos que alguien agrega un tag "a mano en la consola" con la AWS CLI apuntando a moto:
```bash
terraform apply -auto-approve
aws --endpoint-url http://localhost:5000 ec2 create-tags     --resources $(terraform output -raw instance_id) --tags Key=WebServer,Value=Apache
terraform plan
```
```text
# Sin ignore_changes: Terraform quiere BORRAR el cambio manual (drift)
          - "WebServer" = "Apache" -> null
Plan: 0 to add, 1 to change, 0 to destroy.

# Con ignore_changes = [tags] (descomentar bloque)
No changes. Your infrastructure matches the configuration.
```

## 💡 Para recordar
- **Drift** = diferencia entre la nube real y tu código. Por defecto Terraform la **revierte**.
- Usa `ignore_changes` con atributos concretos. `ignore_changes = all` oculta problemas.
- Para limpiar: `terraform destroy -auto-approve` en cada carpeta (en v2, primero quita la protección).

📚 [lifecycle](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle) · Siguiente → [04-01 Input Variables](../../04-variables/04-01-input-variables/)
