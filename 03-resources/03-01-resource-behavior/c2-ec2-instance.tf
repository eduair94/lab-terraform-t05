# Create EC2 Instance
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
#
#  resource  "<RESOURCE TYPE>"  "<LOCAL NAME>" {
#     <ARGUMENTO> = <VALOR>
#  }
resource "aws_instance" "my-ec2-vm" {
  ami               = "ami-047a51fa27710816e" # Amazon Linux
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  #availability_zone = "us-east-1b"   # Paso 3: cambiar AZ -> fuerza REEMPLAZO
  tags = {
    "Name" = "web"
    #"tag1" = "Update-test-1"         # Paso 2: agregar tag -> UPDATE IN-PLACE
  }
}
