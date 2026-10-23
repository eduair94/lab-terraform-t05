# Input Variables
# Sin defaults: los valores los pone el "sistema de CI" (HCP Terraform -> Variables,
# GitHub Actions -> env TF_VAR_aws_region / TF_VAR_instance_type).
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type - Instance Sizing"
  type        = string
}
