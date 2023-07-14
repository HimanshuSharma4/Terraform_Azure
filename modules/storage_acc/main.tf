# module "azurerm_resource_group" {
#     source = "../resource_group"
# }

resource "azurerm_storage_account" "example" 	{
  name                     = "test67546631"
  resource_group_name      = var.rg_st_acc
  location                 = var.rg_st_location
  account_tier             = "Standard"
  account_replication_type = "GRS"

}
