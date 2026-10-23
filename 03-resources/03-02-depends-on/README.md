# 03-02 · Meta-argument `depends_on`

> **En una frase:** Terraform deduce solo el orden de creación a partir de las referencias. `depends_on` sirve para las dependencias que **no** puede deducir.

## 🧠 Lo esencial

**Dependencia implícita** (la que se usa casi siempre). Basta con referenciar otro recurso:
```hcl
resource "aws_subnet" "vpc-dev-public-subnet-1" {
  vpc_id = aws_vpc.vpc-dev.id     # <- Terraform sabe que primero va la VPC
}
```

**Dependencia explícita**. La EIP no referencia al Internet Gateway, pero AWS lo necesita para asociar una IP pública:
```hcl
resource "aws_eip" "my-eip" {
  instance   = aws_instance.my-ec2-vm.id
  domain     = "vpc"
  depends_on = [aws_internet_gateway.vpc-dev-igw]   # <- se lo decimos a mano
}
```

### Arquitectura (9 recursos)
```text
aws_vpc (10.0.0.0/16)
 ├─ aws_subnet (10.0.1.0/24, us-east-1a)
 ├─ aws_internet_gateway ◄──────────────── depends_on ──┐
 ├─ aws_route_table ─ aws_route (0.0.0.0/0 → IGW)       │
 │     └─ aws_route_table_association (→ subnet)        │
 ├─ aws_security_group (22, 80 in / all out)            │
 └─ aws_instance (subnet + SG) ─── aws_eip ─────────────┘
```

## ▶️ Ejecutar (sin AWS)
```bash
terraform init && terraform validate
terraform plan
terraform apply -auto-approve
terraform state list          # lista los 9 recursos
terraform graph               # grafo de dependencias en formato DOT (pegar en https://dreampuf.github.io/GraphvizOnline)
terraform destroy -auto-approve
```

## 👀 Salida real (moto). Fíjate en el orden
```text
aws_vpc.vpc-dev: Creation complete after 7s
aws_internet_gateway.vpc-dev-igw: Creating...        ┐
aws_route_table.vpc-dev-public-route-table: Creating │ en PARALELO:
aws_subnet.vpc-dev-public-subnet-1: Creating...      │ todos solo dependen de la VPC
aws_security_group.dev-vpc-sg: Creating...           ┘
aws_route.vpc-dev-public-route: Creating...          <- espera IGW + route table
aws_instance.my-ec2-vm: Creating...                  <- espera subnet + SG
aws_eip.my-eip: Creating...                          <- ULTIMO: espera instancia + IGW
Apply complete! Resources: 9 added, 0 changed, 0 destroyed.
```
Al destruir, Terraform recorre el grafo al revés: primero la EIP y al final la VPC.

## 💡 Para recordar
- Prefiere **referencias**. Usa `depends_on` solo cuando no exista una.
- Lo que no depende entre sí se crea en paralelo (10 a la vez por defecto, `-parallelism=N`).
- 🔄 **Cambio vs. el lab original:** en el provider AWS v5, `vpc = true` en `aws_eip` se reemplazó por `domain = "vpc"`.
- ⚠️ `key_name = "terraform-key"` solo se necesita en AWS real (crea el key pair antes). Moto no lo valida.

📚 [depends_on](https://developer.hashicorp.com/terraform/language/meta-arguments/depends_on) · Siguiente → [03-03 count](../03-03-count/)
