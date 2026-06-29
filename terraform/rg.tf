resource "azurerm_resource_group" "main" {
  name     = "rg-${local.base}"
  location = var.region
  tags     = local.tags

  lifecycle {
    ignore_changes = [tags["created_date"]]
  }
}

data "azurerm_client_config" "current" {}
