# Create 5 EC2 Instances con UN solo bloque
resource "aws_instance" "web" {
  ami           = "ami-047a51fa27710816e" # Amazon Linux
  instance_type = "t2.micro"
  count         = 5 # Meta-Argument: crea web[0] ... web[4]
  tags = {
    #"Name" = "web"                 # Paso 1: todas se llaman igual
    "Name" = "web-${count.index}" # Paso 2: web-0, web-1, ... web-4
  }
}

# Splat expression [*]: lista con un atributo de TODAS las instancias
output "instance_names" {
  value = aws_instance.web[*].tags.Name
}
