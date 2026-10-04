terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1. Reference your existing active Resource Group
data "azurerm_resource_group" "existing_rg" {
  name = "sysops-automation-rg" 
}

# 2. Reference your existing Subnet (Terraform will just attach to it)
data "azurerm_subnet" "existing_subnet" {
  name                 = "frontend-subnet"     # Make sure this matches your active subnet name
  virtual_network_name = "sysops-prod-vnet"     # Make sure this matches your active VNet name
  resource_group_name  = data.azurerm_resource_group.existing_rg.name
}

# 3. Create the mandatory Network Interface (NIC) for the VM plumbing
resource "azurerm_network_interface" "win_nic" {
  name                = "sysops-win-nic"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.existing_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# 4. Provision the Windows Server Virtual Machine
resource "azurerm_windows_virtual_machine" "sysops_win_vm" {
  name                = "sysops-win-vm"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  location            = data.azurerm_resource_group.existing_rg.location
  size                = "Standard_B2s" # Recommended size for running Windows efficiently
  admin_username      = "sysopsadmin"
  admin_password      = "P@ssw0rd123456!" # Must meet complex password requirements

  network_interface_ids = [
    azurerm_network_interface.win_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}
