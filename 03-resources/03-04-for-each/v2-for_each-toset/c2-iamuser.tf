# Create 4 IAM Users
# for_each NO acepta listas -> toset() convierte la lista en set(string)
resource "aws_iam_user" "myuser" {
  for_each = toset(["Jack", "James", "Madhu", "Dave"])
  name     = each.key # en un set, each.key == each.value
}
