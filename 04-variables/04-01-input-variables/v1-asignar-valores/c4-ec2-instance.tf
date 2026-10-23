# Create EC2 Instance
resource "aws_instance" "my-ec2-vm" {
  ami                    = var.ec2_ami_id
  instance_type          = var.ec2_instance_type
  count                  = var.ec2_instance_count
  key_name               = "terraform-key"
  user_data              = file("apache-install.sh") # funcion file(): lee un archivo local como string
  vpc_security_group_ids = [aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id]
  tags = {
    "Name" = "web-${count.index}"
  }
}
