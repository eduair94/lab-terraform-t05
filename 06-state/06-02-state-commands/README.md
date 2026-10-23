# 06-02 · Comandos de State

> **En una frase:** herramientas para **inspeccionar**, **reparar** y **reorganizar** el state sin tocar la infraestructura real. Úsalas con cuidado.

## 🗺️ Mapa rápido

| Quiero... | Comando | Alternativa moderna (en código) |
|---|---|---|
| Ver un plan guardado | `terraform show plan.out` / `-json` | — |
| Ver el state | `terraform show`, `state list`, `state show <addr>` | — |
| Aceptar cambios hechos a mano | `terraform apply -refresh-only` | (`terraform refresh` es el alias viejo) |
| Renombrar un recurso sin recrearlo | `terraform state mv A B` | bloque **`moved {}`** ✅ |
| Dejar de administrar un recurso (sin borrarlo) | `terraform state rm A` | bloque `removed {}` |
| Adoptar un recurso que ya existe | `terraform import A id` | bloque **`import {}`** ✅ |
| Backup / restauración manual | `terraform state pull` / `push` | — |
| Liberar un lock trabado | `terraform force-unlock <ID>` | — |
| Forzar la recreación | `terraform apply -replace=A` | (`taint` está deprecado) |
| Aplicar solo una parte | `-target=A` | (solo para emergencias) |

## ▶️ Ejecutar (sin AWS). Requisito: [06-00](../06-00-backend-bootstrap/) aplicado
```bash
terraform init -backend-config=backend-moto.hcl
alias awsl='aws --endpoint-url http://localhost:5000'
```

### 1) `show`: leer planes y state
```text
$ terraform show
The state file is empty. No resources are represented.

$ terraform plan -out=v1plan.out        # el plan es un archivo BINARIO
$ terraform show v1plan.out             # versión legible para personas
$ terraform show -json v1plan.out       # versión para máquinas (CI, OPA, Infracost)
[('aws_instance.my-ec2-vm', ['create']), ('aws_security_group.vpc-ssh', ['create']), ...]
$ terraform apply v1plan.out
```

### 2) Drift y `-refresh-only`
Alguien agrega un tag "a mano":
```bash
awsl ec2 create-tags --resources $(terraform output -raw instance_id) --tags Key=demotag,Value=refreshtest
```
```text
$ terraform plan                       # Terraform quiere REVERTIRLO
          - "demotag" = "refreshtest" -> null
Plan: 0 to add, 1 to change, 0 to destroy.

$ terraform apply -refresh-only        # Opción 2: aceptarlo en el STATE
Note: Objects have changed outside of Terraform
          + "demotag" = "refreshtest"
```
Después descomenta `"demotag"` en `c4-ec2-instance.tf` (código = realidad) → `No changes.` ✅
> Orden mental: **refresh → plan → decidir → apply**. Decides tú si el cambio manual se queda (se agrega al código) o se revierte (`apply` normal).

### 3) Renombrar: `state mv` vs. `moved {}`
```text
$ terraform state mv aws_instance.my-ec2-vm aws_instance.my-ec2-vm-new
Successfully moved 1 object(s).

# ❌ MAL USO: no renombraste el código -> Terraform cree que es OTRO recurso
  # aws_instance.my-ec2-vm will be created
  # aws_instance.my-ec2-vm-new will be destroyed
Plan: 1 to add, 0 to change, 1 to destroy.         <- ¡NO hagas apply!

# ✅ BUEN USO: renombras también en el código (y en los outputs)
No changes. Your infrastructure matches the configuration.
```
**Forma moderna:** se escribe en el código, queda en git y se revisa en un PR:
```hcl
moved {
  from = aws_instance.my-ec2-vm-new
  to   = aws_instance.my-ec2-vm
}
```
```text
  # aws_instance.my-ec2-vm-new has moved to aws_instance.my-ec2-vm
Plan: 0 to add, 0 to change, 0 to destroy.
```

### 4) `state rm` y volver con `import {}`
```text
$ terraform state rm aws_instance.my-ec2-vm
Successfully removed 1 resource instance(s).       <- la VM SIGUE existiendo en "AWS"
$ terraform plan
  # aws_instance.my-ec2-vm will be created           <- Terraform ya no la conoce
```
Para recuperarla, crea un archivo `c7-import.tf`:
```hcl
import {
  to = aws_instance.my-ec2-vm
  id = "i-0477a40d61c01681f"     # el ID real
}
```
```text
  # aws_instance.my-ec2-vm will be imported
Plan: 1 to import, 0 to add, 0 to change, 0 to destroy.
Apply complete! Resources: 1 imported, 0 added, 0 changed, 0 destroyed.
```

### 5) `pull` / `push`
```bash
terraform state pull > backup.tfstate     # descarga el state remoto (JSON)
terraform state push backup.tfstate       # lo sube (rechaza un "serial" más viejo, salvo con -force)
```

### 6) Lock y `force-unlock` (probado en vivo)
```text
# Terminal 1: terraform apply -replace=aws_instance.my-ec2-vm   (tarda ~20s)
# Terminal 2: terraform plan
Error: Error acquiring the state lock
Lock Info:
  ID:        6881b34b-d944-044b-6c8a-de22fd218081
  Operation: OperationTypeApply
```
Si el proceso 1 **muere** (Ctrl+C dos veces, se corta la VPN, se cae el runner de CI), el lock queda tomado para siempre:
```text
$ terraform force-unlock 6881b34b-...     # usa el ID que muestra el error
Terraform state has been successfully unlocked!
```
⚠️ Úsalo solo si estás **seguro** de que nadie más está aplicando.

### 7) `-replace` (reemplaza a `taint`)
```text
$ terraform apply -replace="aws_instance.my-ec2-vm"
  # aws_instance.my-ec2-vm will be replaced, as requested
aws_instance.my-ec2-vm: Destroying...
aws_instance.my-ec2-vm: Creating...
Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
```
Caso típico: cambiaste el `user_data` (solo se ejecuta al primer arranque) y necesitas una VM nueva.

### 8) `-target`
Tres cambios a la vez: un tag en la VM, el puerto 8080 en el SG `vpc-web` y una VM nueva (`my-demo-vm`):
```text
$ terraform plan                                   # todo
Plan: 1 to add, 2 to change, 0 to destroy.

$ terraform plan -target=aws_instance.my-ec2-vm    # solo la VM + sus DEPENDENCIAS (el SG)
Plan: 0 to add, 2 to change, 0 to destroy.         <- la VM nueva queda afuera
Warning: Resource targeting is in effect
```

## 💡 Para recordar
- Antes de usar `state mv`/`rm` en un backend remoto, haz `terraform state pull > backup.tfstate`. Con el state **local**, Terraform crea solo `terraform.tfstate.<timestamp>.backup`.
- Prefiere `moved` / `import` / `removed` (código revisable en un PR) a los comandos sueltos.
- `-target` y `force-unlock` son para **emergencias**, no para el día a día.
- Limpieza: `terraform destroy -auto-approve`.

📚 [State CLI](https://developer.hashicorp.com/terraform/cli/state) · [moved](https://developer.hashicorp.com/terraform/language/moved) · [import](https://developer.hashicorp.com/terraform/language/import) · Siguiente → [07 Workspaces](../../07-workspaces/)
