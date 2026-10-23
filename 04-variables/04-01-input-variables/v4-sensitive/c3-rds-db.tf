# Warning: Never check sensitive values like usernames and passwords into source control.
# Create RDS MySQL Database
resource "aws_db_instance" "db1" {
  identifier          = "mydb1"
  allocated_storage   = 5
  engine              = "mysql"
  instance_class      = "db.t3.micro" # db.t2.* ya no existe
  db_name             = "mydb1"       # aws v4+: "name" -> "db_name"
  username            = var.db_username
  password            = var.db_password
  skip_final_snapshot = true
}

output "db_endpoint" {
  value = aws_db_instance.db1.endpoint
}
