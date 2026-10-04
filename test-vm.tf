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

# 1. Reference your CORRECT existing Resource Group name
data "azurerm_resource_group" "existing_rg" {
  name = "sysops-terraform-rg"      # <--- TARGET NAME CORRECTION INJECTED HERE
}

# 2. Automatically build a clean Virtual Network inside that group
resource "azurerm_virtual_network" "pipeline_vnet" {
  name                = "sysops-pipeline-vnet"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  address_space       = ["10.0.0.0/16"]
}

# 3. Create a fresh Subnet inside the new VNet
resource "azurerm_subnet" "pipeline_subnet" {
  name                 = "frontend-subnet"
  resource_group_name  = data.azurerm_resource_group.existing_rg.name
  virtual_network_name = azurerm_virtual_network.pipeline_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 4. Create the mandatory Network Interface Card (NIC) for the VM
resource "azurerm_network_interface" "win_nic" {
  name                = "sysops-win-nic"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.pipeline_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# 5. Provision the Standalone Windows Server VM
resource "azurerm_windows_virtual_machine" "sysops_win_vm" {
  name                = "sysops-win-vm"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  location            = data.azurerm_resource_group.existing_rg.location
  size                = "Standard_B2s" 
  admin_username      = "sysopsadmin"
  admin_password      = "P@ssw0rd123456!" # Complex password meeting Azure requirements

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
