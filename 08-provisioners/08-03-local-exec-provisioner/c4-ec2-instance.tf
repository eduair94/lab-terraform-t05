# Create EC2 Instance - Amazon Linux 2023
resource "aws_instance" "my-ec2-vm" {
  ami                    = data.aws_ami.amzlinux.id
  instance_type          = var.instance_type
  user_data              = file("apache-install.sh")
  vpc_security_group_ids = [aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id]
  tags = {
    "Name" = "local-exec-demo"
  }

  # local-exec provisioner (Creation-Time Provisioner - Triggered during Create Resource)
  # Corre en TU maquina (no en la EC2) -> no necesita SSH ni key pair.
  provisioner "local-exec" {
    command     = "echo ${self.private_ip} >> creation-time-private-ip.txt"
    working_dir = "local-exec-output-files/"
    #on_failure = continue
  }

  # local-exec provisioner - (Destroy-Time Provisioner - Triggered during Destroy Resource)
  provisioner "local-exec" {
    when        = destroy
    command     = "echo Destroy-time provisioner Instance Destroyed at ${timestamp()} >> destroy-time.txt"
    working_dir = "local-exec-output-files/"
  }
}

output "private_ip" {
  value = aws_instance.my-ec2-vm.private_ip
}
