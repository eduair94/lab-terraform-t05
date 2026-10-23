# Define Output Values
# Splat [*]: lista con el atributo de TODAS las instancias del count
output "ec2_instance_publicip" {
  description = "EC2 Instance Public IP"
  value       = aws_instance.my-ec2-vm[*].public_ip
}

output "ec2_names" {
  value = aws_instance.my-ec2-vm[*].tags.Name
}

output "workspace" {
  value = terraform.workspace
}
