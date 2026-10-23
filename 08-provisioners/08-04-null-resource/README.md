# 08-04 · `null_resource`, `time_sleep` y `terraform_data`

> **En una frase:** `null_resource` es un recurso "vacío" que solo sirve para colgarle provisioners. Con `triggers` decides **cuándo** se vuelven a ejecutar.

## 🧠 Lo esencial
```hcl
resource "time_sleep" "wait_10_seconds" {             # pausa explícita (en EC2: 90s)
  depends_on      = [docker_container.my-ec2-vm]
  create_duration = "10s"
}

resource "null_resource" "sync_app1_static" {
  depends_on = [time_sleep.wait_10_seconds]
  triggers = {
    always-update = timestamp()     # cambia SIEMPRE -> se recrea en CADA apply
  }
  connection { ... }
  provisioner "file"        { source = "apps/app1", destination = "/tmp" }
  provisioner "remote-exec" { inline = ["sudo cp -r /tmp/app1 /var/www/html"] }
}
```
**⭐ Versión moderna (incluida en el código):** `terraform_data` es built-in (Terraform ≥ 1.4, no necesita el provider `null`). En vez de `timestamp()` usa un **hash del contenido**, así solo se re-ejecuta si cambió algún archivo:
```hcl
resource "terraform_data" "sync_app1_on_change" {
  triggers_replace = sha1(join("", [
    for f in fileset("${path.module}/apps/app1", "**") : filesha1("${path.module}/apps/app1/${f}")
  ]))
  ...
}
```

## ▶️ Ejecutar (sin AWS, con Docker)
```bash
terraform init && terraform apply -auto-approve
curl http://localhost:8080/app1/file1.html
terraform plan                                  # ¿qué pasa sin cambiar nada?
echo '<h1>App1 File3</h1>' > apps/app1/file3.html
echo '<h1>App1 File1 - Updated</h1>' > apps/app1/file1.html
terraform apply -auto-approve
curl http://localhost:8080/app1/file3.html
```

## 👀 Salida real
```text
time_sleep.wait_10_seconds: Creation complete after 10s
null_resource.sync_app1_static: Creation complete after 1s
terraform_data.sync_app1_on_change: Creation complete after 1s
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

# plan SIN cambiar archivos
  # null_resource.sync_app1_static must be replaced    <- timestamp(): corre siempre
Plan: 1 to add, 0 to change, 1 to destroy.             <- terraform_data NO aparece ✅

# plan DESPUÉS de cambiar archivos
  # null_resource.sync_app1_static must be replaced
  # terraform_data.sync_app1_on_change must be replaced <- ahora sí: cambió el hash
Plan: 2 to add, 0 to change, 2 to destroy.

app1/file1.html    -> <h1>App1 File1 - Updated</h1>
app1/file3.html    -> <h1>App1 File3</h1>
app1-v2/file3.html -> <h1>App1 File3</h1>
```

## 💡 Para recordar
- `timestamp()` en un trigger = el plan **nunca** queda limpio. Es útil para aprender, pero molesta en CI (siempre muestra cambios).
- ⚠️ Recursos **sin dependencia entre sí corren en paralelo**. Nos pasó al correr `scripts/test-all.sh`: `null_resource` y `terraform_data` copiaban a `/tmp/app1` al mismo tiempo → `scp: /tmp/app1: File exists`. Solución: carpetas distintas (o `depends_on` entre ellos).
- `time_sleep` sirve para "esperar a que algo esté listo". Si puedes, espera a una condición real (ver 08-02).
- Para limpiar: `terraform destroy -auto-approve` y luego `git checkout apps/ && git clean -f apps/` (restaura `file1.html` y borra `file3.html`).

📚 [terraform_data](https://developer.hashicorp.com/terraform/language/resources/terraform-data) · [time_sleep](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) · Siguiente → [09-01 Modules](../../09-modules/09-01-module-basics/)
