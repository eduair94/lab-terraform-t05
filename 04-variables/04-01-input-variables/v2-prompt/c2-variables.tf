variable "aws_region" {
  description = "Region in which AWS resources to be created"
  type        = string
  default     = "us-east-1"
}

# Sin "default" -> Terraform PREGUNTA el valor en plan/apply
variable "ec2_instance_type" {
  description = "EC2 Instance Type"
  type        = string
}
