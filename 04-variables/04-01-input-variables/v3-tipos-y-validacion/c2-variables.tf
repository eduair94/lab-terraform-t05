variable "aws_region" {
  description = "Region in which AWS resources to be created"
  type        = string
  default     = "us-east-1"
}

# Validacion: el AMI tiene que empezar con "ami-"
variable "ec2_ami_id" {
  description = "AMI ID"
  type        = string
  default     = "ami-0915bcb5fa77e4892"
  validation {
    condition     = length(var.ec2_ami_id) > 4 && substr(var.ec2_ami_id, 0, 4) == "ami-"
    error_message = "The ec2_ami_id value must be a valid AMI id, starting with \"ami-\"."
  }
}

# list(string): se accede por POSICION -> var.ec2_instance_type_list[0]
variable "ec2_instance_type_list" {
  description = "EC2 Instance Type using list"
  type        = list(string)
  default     = ["t3.micro", "t3.small", "t3.medium"]
}

# map(string): se accede por CLAVE -> var.ec2_instance_type_map["small-apps"]
variable "ec2_instance_type_map" {
  description = "EC2 Instance Type using maps"
  type        = map(string)
  default = {
    "small-apps"  = "t3.micro"
    "medium-apps" = "t3.medium"
    "big-apps"    = "t3.large"
  }
}

variable "ec2_instance_tags" {
  description = "EC2 Instance Tags"
  type        = map(string)
  default = {
    "Name" = "ec2-web"
    "Tier" = "Web"
  }
}
