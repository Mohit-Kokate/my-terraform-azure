# 1. Tell Terraform to use the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# 2. Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# 3. Create a simple Resource Group for your SysOps practice
resource "azurerm_resource_group" "practice_rg" {
  name     = "sysops-terraform-rg"
  location = "East US"
}
