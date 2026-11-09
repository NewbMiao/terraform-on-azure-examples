# The database admin password exists only here: no plaintext in config, state remembers it via random_password.
#
# When adopting an existing server, import it — the import id is the live password string:
#
#   terraform import random_password.admin '<live password>'
#
# After importing, length must match the live one; a mismatch makes plan rebuild random_password.
resource "random_password" "admin" {
  length  = 24
  special = true
}
