terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.33.0"
    }
  }
}

provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {}
}

variable "prefix" {
  default = "th"
  type = string
}

resource "azurerm_resource_group" "rg" {
  name = "website-tw"
  location = "East US 2"
}

resource "azurerm_static_site" "site" {
  name                = "website-tw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_tier = "Free"
}