# Output variable definitions
# module.<NOMBRE>.<OUTPUT>: solo se puede leer lo que el modulo expone en sus outputs.
output "ec2_instance_public_ip" {
  description = "Public IP addresses of EC2 instances"
  value       = { for k, m in module.ec2_cluster : k => m.public_ip }
}

output "ec2_instance_public_dns" {
  description = "Public DNS of EC2 instances"
  value       = { for k, m in module.ec2_cluster : k => m.public_dns }
}
