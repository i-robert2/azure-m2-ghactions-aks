output "resource_group" {
  value = azurerm_resource_group.main.name
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "acr_name" {
  value = azurerm_container_registry.main.name
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

output "key_vault_name" {
  value = azurerm_key_vault.main.name
}

output "pg_fqdn" {
  value = azurerm_postgresql_flexible_server.main.fqdn
}

output "pg_admin_login" {
  value = var.pg_admin_login
}

output "app_identity_client_id" {
  value = azurerm_user_assigned_identity.app.client_id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "aks_oidc_issuer" {
  value = azurerm_kubernetes_cluster.main.oidc_issuer_url
}
