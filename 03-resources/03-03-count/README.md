# 03-03 · Meta-argument `count`

> **En una frase:** con `count = N` creas N copias del mismo recurso, y `count.index` (0, 1, 2...) te permite distinguirlas.

## 🧠 Lo esencial
```hcl
resource "aws_instance" "web" {
  count = 5
  tags  = { "Name" = "web-${count.index}" }   # web-0 ... web-4
}
```
- En el state queda como una **lista**: `aws_instance.web[0]`, `aws_instance.web[1]`...
- Para leer un atributo de todas: **splat** `aws_instance.web[*].id`.
- Uso típico: `count = var.enabled ? 1 : 0` para crear un recurso de forma condicional.

## ▶️ Ejecutar (sin AWS)
```bash
terraform init
terraform apply -auto-approve
terraform state list
terraform destroy -auto-approve
```

## 👀 Salida real (moto)
```text
aws_instance.web[2]: Creation complete after 12s [id=i-2ed97c06659f490c6]
aws_instance.web[0]: Creation complete after 12s [id=i-d253be3ad64f183c4]
...
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:
instance_names = ["web-0", "web-1", "web-2", "web-3", "web-4"]

$ terraform state list
aws_instance.web[0]
aws_instance.web[1]
...
aws_instance.web[4]
```

## 💡 Para recordar
- ⚠️ La identidad de cada copia es su **posición**. Si borras un elemento del medio de una lista, todos los que siguen "se corren" y Terraform los modifica o recrea. Lo ves en el experimento [03-04 v3](../03-04-for-each/v3-count-vs-for_each/).
- `count` y `for_each` no se pueden usar juntos en el mismo bloque.

📚 [count](https://developer.hashicorp.com/terraform/language/meta-arguments/count) · Siguiente → [03-04 for_each](../03-04-for-each/)
