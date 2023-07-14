
# resource "azurerm_linux_virtual_machine" "vm" {
#   name                  = var.vmname
#   resource_group_name   = var.resource_group_name
#   location              = var.location
#   size                  = var.vm_size
#   admin_username        = module.key_vault.db_pwd_name
#   admin_password        = module.key_vault.db_pwd_value
#   network_interface_ids = var.network_interface_ids
#   admin_ssh_key {
#     username   = module.key_vault.db_pwd_name
#     public_key = file("/home/knoldus/.ssh/id_rsa.pub")
#   }

#   os_disk {
#     name                 = "${var.vmname}-os-disk-01"
#     caching              = "ReadWrite"
#     storage_account_type = var.os_disk_type
#   }
#   source_image_reference {
#     publisher = var.image_publisher
#     offer     = var.image_offer
#     sku       = var.image_sku
#     version   = "latest"
#   }
# }


provider "azurerm" {
  features {}
}



# resource_group
resource "azurerm_resource_group" "rg" {
  name     = "terra_rg"
  location = "Brazil South"
}

data "key_vault" "my_kv"{
    # source = "../kingstorm_demo"
  
}


#virtual_network within the above resource group
resource "azurerm_virtual_network" "vnet" {
  name                = "teraa_vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/28"]
}

resource "azurerm_subnet" "sub" {
  name                 = var.azurerm_subnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/29"]
}

resource "azurerm_public_ip" "pubIP" {
  name                = var.azurerm_public_ip
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

#network_security_group
resource "azurerm_network_security_group" "nsg" {
  name                = "terra-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "test1"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "terra-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pubIP.id

    # private_ip_address_allocation = "Static"
    # private_ip_address            = "10.0.0.${count.index + 10}"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_nic_asso" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "terra-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = data.key_vault.my_kv.db_pwd_name
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = data.key_vault.my_kv.db_pwd_name
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}