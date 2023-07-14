data "azurerm_client_config" "current" {}

variable "rg_name" {
  type = string
  default = "ps-rg-vault"
}

variable "rg_location" {
  type = string
  default = "east us"
}


module "azurerm_resource_group"{
  source = "../resource_group"
  azurerm_resource_group_name = var.rg_name
  azurerm_resource_group_location = var.rg_location
}

# module "storage_acc" {
#   source = "../storage_acc"
#   # rg_st_acc = var.rg_name
#   # rg_st_location = var.rg_location

# }

resource "azurerm_key_vault" "example" {
  name                        = "examplepstersakeyvault"
  location                    = module.azurerm_resource_group.rg_location
  resource_group_name         = module.azurerm_resource_group.rg_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  # access_policy {
  #   tenant_id = data.azurerm_client_config.current.tenant_id
  #   object_id = data.azurerm_client_config.current.object_id

  #   key_permissions = [
  #     "Get",
  #   ]

  #   secret_permissions = [
  #     "Get",
  #   ]

  #   storage_permissions = [
  #     "Get",
  #   ]
  # }
}