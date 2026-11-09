# Plays azurerm_postgresql_flexible_server: the password travels via the two write-only fields; the version decides whether it ships.
#
# The real resource has one more field, administrator_password_wo = random_password.admin.result;
# it enters neither state nor diff, so there is no matching input field here — writing it in would make
# terraform_data treat "the value changed" as a change, the exact opposite of real behavior.
resource "terraform_data" "server" {
  input = {
    name                              = var.server.name
    administrator_login               = var.administrator_login
    administrator_password_wo         = random_password.admin.result
    administrator_password_wo_version = var.admin_password_version
  }
}
