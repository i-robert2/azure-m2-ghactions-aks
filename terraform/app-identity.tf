# Workload identity for the API pod: lets it read Key Vault via the CSI driver
# without any stored Kubernetes Secret.
resource "azurerm_user_assigned_identity" "app" {
  name                = "id-${local.base}-app"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.tags

  lifecycle { ignore_changes = [tags["created_date"]] }
}

# Federate the Kubernetes ServiceAccount app/notes-api to this identity.
resource "azurerm_federated_identity_credential" "app" {
  name                = "notes-api-fed"
  resource_group_name = azurerm_resource_group.main.name
  parent_id           = azurerm_user_assigned_identity.app.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.main.oidc_issuer_url
  subject             = "system:serviceaccount:app:notes-api"
}

# Allow the app identity to read Key Vault secrets.
resource "azurerm_role_assignment" "app_kv_reader" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}
