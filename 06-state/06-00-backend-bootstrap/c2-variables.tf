variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Bucket S3 para guardar los terraform.tfstate"
  type        = string
  default     = "terraform-devopslab-state"
}

variable "lock_table_name" {
  description = "Tabla DynamoDB para el state locking"
  type        = string
  default     = "terraform-dev-state-table"
}
