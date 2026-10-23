# EXTRA (no esta en el lab original) - corre 100% local, sin AWS ni moto.
# Muestra POR QUE for_each es mas seguro que count cuando la lista cambia.
#
# terraform_data es un recurso built-in de Terraform (no crea nada real):
# ideal para experimentar con el comportamiento del state.
terraform {
  required_version = ">= 1.6"
}

variable "users" {
  type    = list(string)
  default = ["ana", "beto", "carla"]
}

# Con count: la identidad de cada recurso es su POSICION (0, 1, 2)
resource "terraform_data" "with_count" {
  count = length(var.users)
  input = var.users[count.index]
}

# Con for_each: la identidad de cada recurso es su CLAVE ("ana", "beto", ...)
resource "terraform_data" "with_for_each" {
  for_each = toset(var.users)
  input    = each.value
}
