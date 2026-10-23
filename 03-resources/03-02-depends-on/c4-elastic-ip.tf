# Resource-9: Create Elastic IP
resource "aws_eip" "my-eip" {
  instance = aws_instance.my-ec2-vm.id
  domain   = "vpc" # (aws v5) reemplaza al viejo "vpc = true"

  # Meta-Argument: la EIP solo se crea cuando el Internet Gateway ya existe.
  # Terraform no lo puede inferir (la EIP no referencia al IGW), por eso lo explicitamos.
  depends_on = [aws_internet_gateway.vpc-dev-igw]
}
