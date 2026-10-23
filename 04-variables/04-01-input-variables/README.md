# 04-01 · Input Variables

> **En una frase:** las variables son los **parámetros** de tu código. El mismo `.tf` sirve para dev, qa o prod; solo cambian los valores que le pasas.

## 🧠 Lo esencial
```hcl
variable "ec2_instance_type" {
  description = "EC2 Instance Type"
  type        = string        # string | number | bool | list(..) | map(..) | object({..})
  default     = "t3.micro"    # opcional. Si no hay default, Terraform lo pide.
  sensitive   = false         # true = lo oculta en plan/apply
  validation { ... }          # reglas propias
}
# Se usa con:  var.ec2_instance_type
```

### 🏆 ¿Qué valor gana? (de menor a mayor prioridad)
```text
default  <  TF_VAR_xxx (env)  <  terraform.tfvars  <  *.auto.tfvars  <  -var / -var-file (CLI)
```
Si pasas varios `-var`/`-var-file`, **gana el último**.

| Carpeta | Lab original | Tema |
|---|---|---|
| [v1-asignar-valores](v1-asignar-valores/) | v1, v3, v4, v5, v6, v7, v11 | Todas las formas de asignar valores, la precedencia y `file()` |
| [v2-prompt](v2-prompt/) | v2 | Variable sin default: Terraform la pide |
| [v3-tipos-y-validacion](v3-tipos-y-validacion/) | v8, v9 | `list`, `map`, `validation`, `terraform console` |
| [v4-sensitive](v4-sensitive/) | v10 | `sensitive = true` + RDS |

---

## 🧪 v1 · Experimento de precedencia (salida real)
`terraform console` evalúa expresiones sin crear nada. Es la forma más rápida de ver qué valor toma una variable:

```bash
cd v1-asignar-valores && terraform init
echo 'var.ec2_instance_type' | terraform console
```
| # | Situación | Comando | Resultado |
|---|---|---|---|
| 1 | Solo `default` (sin terraform.tfvars) | `... \| terraform console` | `"t3.micro"` |
| 2 | Variable de entorno | `export TF_VAR_ec2_instance_type=t3.medium` | `"t3.medium"` |
| 3 | + `terraform.tfvars` (`t3.small`) | — se carga solo — | `"t3.small"` ← **gana al env** |
| 4 | + `web.auto.tfvars` (`t3.2xlarge`) | `echo 'ec2_instance_type = "t3.2xlarge"' > web.auto.tfvars` | `"t3.2xlarge"` |
| 5 | `-var-file` | `terraform console -var-file=web.tfvars` | `"t3.large"` |
| 6 | `-var` después | `... -var-file=web.tfvars -var=ec2_instance_type=t3.nano` | `"t3.nano"` |
| 7 | orden inverso | `... -var=ec2_instance_type=t3.nano -var-file=app.tfvars` | `"t3.xlarge"` ← último gana |

> Borra `web.auto.tfvars` después del experimento: se carga **siempre**, aunque no lo nombres.

**Plan guardado (`-out`)**: congela los valores para que el `apply` haga exactamente lo que revisaste.
```bash
terraform plan -var="ec2_instance_type=t3.large" -var="ec2_instance_count=2" -out v3out.plan
terraform apply v3out.plan           # no pregunta ni recalcula
# Plan: 4 to add  (2 instancias + 2 security groups)
```
**`file()`**: `user_data = file("apache-install.sh")` lee el script como texto. Así el bash queda en su propio archivo.

## 🧪 v2 · Prompt
```text
$ terraform plan
var.ec2_instance_type
  EC2 Instance Type
  Enter a value: t3.medium
      + instance_type = "t3.medium"

$ terraform plan -input=false        # en CI no hay nadie para responder
Error: No value for required variable
```

## 🧪 v3 · Tipos, funciones y validación
```text
length("hello")                                 => 5
length(["a", "b", "c"])                         => 3      (lista)
length({"key1"="value1", "key2"="value2"})      => 2      (map)
substr("Lab", 0, 1)                             => "L"
substr("Lab", 1, 4)                             => "ab"   (no falla si te pasas del largo)
var.ec2_instance_type_list[0]                   => "t3.micro"   (list: por POSICIÓN)
var.ec2_instance_type_map["big-apps"]           => "t3.large"   (map:  por CLAVE)
```
```text
$ terraform plan -var="ec2_ami_id=0915bcb5"
Error: Invalid value for variable
    │ var.ec2_ami_id is "0915bcb5"
The ec2_ami_id value must be a valid AMI id, starting with "ami-".
```
La validación **corta antes de llamar a AWS**: el error aparece sin crear nada.

## 🧪 v4 · Variables sensibles
```bash
cp secrets.tfvars.example secrets.tfvars     # secrets.tfvars está en .gitignore
terraform apply -var-file=secrets.tfvars
```
```text
# En el plan:
      + password = (sensitive value)
      + username = (sensitive value)

# Pero en el state...
$ grep -E '"(password|username)"' terraform.tfstate
            "password": "cambiame-1234",     <- ⚠️ ¡en texto plano!
            "username": "admin",
```
🔐 **Conclusión:** `sensitive` solo oculta el valor en la **pantalla**. El **state** también debe protegerse (backend remoto cifrado, ver sección 06). En Terraform 1.11+ existe `password_wo` (*write-only*): el valor se envía a AWS pero **no se guarda** en el state.

## 💡 Para recordar
- Nunca subas `secrets.tfvars` ni `*.tfstate` a git (ver `.gitignore` del repo).
- `terraform.tfvars` y `*.auto.tfvars` se cargan solos. Cualquier otro nombre requiere `-var-file`.
- 🔄 **Cambios vs. el lab original:** 12 carpetas casi idénticas se agruparon en 4. En RDS: `name` → `db_name` y `db.t2.micro` → `db.t3.micro`.

📚 [Variables](https://developer.hashicorp.com/terraform/language/values/variables) · Siguiente → [04-02 Outputs](../04-02-output-values/)
