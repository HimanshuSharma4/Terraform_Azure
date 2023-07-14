provider "azurerm" {
  features {   
  }
}

variable "rg_name" {
  type = string
  default = "hs-rg-vault"
}

variable "rg_location" {
  type = string
  default = "east us"
}

module "storage_acc" {
  source = "../storage_acc"
  rg_st_acc = module.azurerm_resource_group.rg_name
  rg_st_location = module.azurerm_resource_group.rg_location

  depends_on = [ module.azurerm_resource_group ]
}

module "azurerm_resource_group"{
  source = "../resource_group"
  azurerm_resource_group_name = var.rg_name
  azurerm_resource_group_location = var.rg_location
}

resource "azurerm_virtual_network" "v_net" {
  name                = "vnet-network"
  location            = module.azurerm_resource_group.rg_location
  resource_group_name = module.azurerm_resource_group.rg_name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}