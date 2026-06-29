resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${local.base}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags

  lifecycle { ignore_changes = [tags["created_date"]] }
}

resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-${local.base}-aks"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.tags

  lifecycle { ignore_changes = [tags["created_date"]] }
}

# AKS control-plane identity needs Network Contributor on the vNet to assign IPs.
resource "azurerm_role_assignment" "aks_network" {
  scope                = azurerm_virtual_network.main.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${local.base}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  dns_prefix          = "aks-${local.base}"
  sku_tier            = "Free"
  tags                = local.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  default_node_pool {
    name                         = "system"
    vm_size                      = "Standard_B2s_v2"
    node_count                   = 1
    vnet_subnet_id               = azurerm_subnet.aks.id
    only_critical_addons_enabled = true # keep app workloads on the user pool
    upgrade_settings {
      max_surge = "10%"
    }
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "cilium"
    network_data_plane  = "cilium"
    pod_cidr            = "10.244.0.0/16"
    service_cidr        = "10.0.0.0/16"
    dns_service_ip      = "10.0.0.10"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "5m"
  }

  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  lifecycle {
    ignore_changes = [
      tags["created_date"],
      default_node_pool[0].node_count,
    ]
  }

  depends_on = [azurerm_role_assignment.aks_network]
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_B2s_v2"
  node_count            = 1
  vnet_subnet_id        = azurerm_subnet.aks.id
  mode                  = "User"
  tags                  = local.tags

  lifecycle { ignore_changes = [tags["created_date"], node_count] }
}

# Let AKS pull from ACR using its kubelet identity.
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}
