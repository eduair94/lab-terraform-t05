# Terraform Block
terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Con HCP Terraform (ex Terraform Cloud) agregarias esto y el state/runs vivirian alla:
  # cloud {
  #   organization = "tu-org"
  #   workspaces {
  #     name = "terraform-cloud-demo1"
  #   }
  # }
}

# Provider Block
provider "aws" {
  region = var.aws_region
}
