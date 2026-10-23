# 03-01 · Sintaxis y comportamiento de un `resource`

> **En una frase:** escribes cómo quieres la infraestructura (*desired state*); Terraform la compara con lo que anotó en `terraform.tfstate` (*current state*) y decide si **crea**, **actualiza**, **reemplaza** o **destruye**.

## 🧠 Lo esencial

```hcl
resource "aws_instance" "my-ec2-vm" {   # tipo + nombre local  -> dirección: aws_instance.my-ec2-vm
  ami               = "ami-047a51fa27710816e"   # argumentos
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
}
```

| Pieza | Qué es |
|---|---|
| **Resource type** (`aws_instance`) | Qué cosa crear. El prefijo (`aws_`) indica el provider. |
| **Local name** (`my-ec2-vm`) | Nombre interno. Solo existe dentro de Terraform. |
| **Arguments** | Configuración del recurso (`ami`, `instance_type`...). |
| **Meta-arguments** | Argumentos de Terraform, no de AWS: `count`, `for_each`, `depends_on`, `lifecycle`, `provider`. |

**Los 4 comportamientos posibles** (símbolo que muestra el `plan`):

| Símbolo | Acción | Cuándo pasa |
|:-:|---|---|
| `+` | create | El recurso está en el código pero no en el state. |
| `~` | update in-place | Cambia un atributo que AWS puede modificar en caliente (ej: tags). |
| `-/+` | destroy and re-create | Cambia un atributo que **no** se puede modificar (ej: AZ). El plan lo marca `# forces replacement`. |
| `-` | destroy | El recurso ya no está en el código, o corres `terraform destroy`. |

## ▶️ Ejecutar (sin AWS)

```bash
terraform init && terraform validate && terraform fmt
terraform plan                 # + create
terraform apply -auto-approve  # aparece terraform.tfstate
```
1. Descomenta `"tag1" = "Update-test-1"` → `terraform plan` → `apply`
2. Cambia la AZ a `us-east-1b` → `terraform plan` → `apply`
3. `terraform destroy -auto-approve`

## 👀 Salida real (moto)

```text
# Paso 1: crear
  # aws_instance.my-ec2-vm will be created
Plan: 1 to add, 0 to change, 0 to destroy.

# Paso 2: agregar un tag
  # aws_instance.my-ec2-vm will be updated in-place
      ~ tags = {
          + "tag1" = "Update-test-1"
Plan: 0 to add, 1 to change, 0 to destroy.

# Paso 3: cambiar la AZ
  # aws_instance.my-ec2-vm must be replaced
      ~ availability_zone = "us-east-1a" -> "us-east-1b" # forces replacement
Plan: 1 to add, 0 to change, 1 to destroy.

# Paso 4: destruir
Destroy complete! Resources: 1 destroyed.
```

## 💡 Para recordar
- `terraform.tfstate` es un JSON y es la **memoria** de Terraform. Nunca lo edites a mano.
- Lee siempre el `plan` antes del `apply`. Un `-/+` en producción significa **downtime**.
- `tags_all` = tus tags + los `default_tags` del provider. Por eso aparecen dos cambios.

📚 [State](https://developer.hashicorp.com/terraform/language/state) · Siguiente → [03-02 depends_on](../03-02-depends-on/)
