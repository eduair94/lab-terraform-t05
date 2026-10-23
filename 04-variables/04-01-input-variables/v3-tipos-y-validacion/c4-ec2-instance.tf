# Create EC2 Instance
resource "aws_instance" "my-ec2-vm" {
  ami           = var.ec2_ami_id
  instance_type = var.ec2_instance_type_list[1] # -> t3.small
  #instance_type = var.ec2_instance_type_map["big-apps"] # -> t3.large
  vpc_security_group_ids = [aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id]
  tags                   = var.ec2_instance_tags
}
