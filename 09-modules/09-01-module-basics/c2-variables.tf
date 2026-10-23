# Input Variables
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

# Detailed monitoring (CloudWatch cada 1 min). Moto NO implementa MonitorInstances,
# por eso el default es false. En AWS real: -var=detailed_monitoring=true
variable "detailed_monitoring" {
  description = "Enable EC2 detailed monitoring"
  type        = bool
  default     = false
}
