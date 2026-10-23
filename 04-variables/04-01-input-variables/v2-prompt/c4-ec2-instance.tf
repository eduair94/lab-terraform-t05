resource "aws_instance" "my-ec2-vm" {
  ami           = "ami-0915bcb5fa77e4892" # Amazon Linux
  instance_type = var.ec2_instance_type
  tags = {
    "Name" = "prompt-demo"
  }
}
