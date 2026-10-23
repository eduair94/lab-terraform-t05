# Terraform Block
terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider Block
# Credenciales: se toman de AWS CLI / variables de entorno (no se hardcodean).
provider "aws" {
  region = "us-east-1"
}
