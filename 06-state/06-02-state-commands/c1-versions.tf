# Terraform Block
terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend S3: el state vive en un bucket, no en tu disco
  backend "s3" {
    bucket = "terraform-devopslab-state" # nombres S3: unicos globalmente y en minusculas
    key    = "statecommands/terraform.tfstate"
    region = "us-east-1"

    # State Locking con DynamoDB (tabla con partition key "LockID" tipo String)
    dynamodb_table = "terraform-dev-state-table"

    # Alternativa moderna (Terraform >= 1.10): lock nativo en S3, sin DynamoDB.
    # dynamodb_table esta deprecado desde 1.11 en favor de esto:
    # use_lockfile = true
  }
}

# Provider Block
provider "aws" {
  region = var.aws_region
}
