# AWS EC2 Instance Module (Terraform Registry)
# https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws
module "ec2_cluster" {
  source  = "terraform-aws-modules/ec2-instance/aws" # <namespace>/<nombre>/<provider>
  version = "~> 5.0"                                 # SIEMPRE fijar version

  # La v2 del modulo tenia "instance_count = 2". Desde la v3 se usa el
  # meta-argument for_each (o count) SOBRE EL MODULO:
  for_each = toset(["one", "two"])

  name = "my-modules-demo-${each.key}"

  ami                    = data.aws_ami.amzlinux.id
  instance_type          = "t2.micro"
  key_name               = "terraform-key"
  monitoring             = var.detailed_monitoring
  vpc_security_group_ids = [data.aws_security_group.default.id]
  subnet_id              = data.aws_subnets.default.ids[0]
  user_data              = file("apache-install.sh")

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
