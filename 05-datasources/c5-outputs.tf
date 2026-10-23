# Define Output Values
output "ami_id" {
  description = "AMI elegido por el data source"
  value       = data.aws_ami.amzlinux.id
}

output "ami_name" {
  value = data.aws_ami.amzlinux.name
}

output "ec2_instance_publicip" {
  description = "EC2 Instance Public IP"
  value       = aws_instance.my-ec2-vm.public_ip
}

output "ec2_publicdns" {
  description = "Public DNS URL of an EC2 Instance"
  value       = aws_instance.my-ec2-vm.public_dns
}
