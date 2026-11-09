# harbor · runtime secret in KV (no expiration_date) — Intentional skip, same convention as team PG/image secrets.
resource "azurerm_key_vault_secret" "harbor_runtime" {
  name         = "harbor-runtime-config-demo"
  value        = "placeholder-not-a-real-secret"
  content_type = "text/plain"
  key_vault_id = azurerm_key_vault.harbor.id

  depends_on = [azurerm_key_vault.harbor]
}
