resource "random_password" "pg_admin" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_key_vault_secret" "pg_admin_password" {
  name         = "pg-admin-password"
  value        = random_password.pg_admin.result
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_role_assignment.kv_admin_self]
}

# The API pod reads this (same value for simplicity in a learning lab).
resource "azurerm_key_vault_secret" "pg_app_password" {
  name         = "pg-app-password"
  value        = random_password.pg_admin.result
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_role_assignment.kv_admin_self]
}
