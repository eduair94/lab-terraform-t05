# Create EC2 Instance
resource "aws_instance" "web" {
  ami               = "ami-0915bcb5fa77e4892" # Amazon Linux
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  #availability_zone = "us-east-1b"
  tags = {
    "Name" = "web-1"
  }
  /*
  # Paso 2: descomentar -> primero CREA el nuevo, despues DESTRUYE el viejo
  lifecycle {
    create_before_destroy = true
  }
  */
}
