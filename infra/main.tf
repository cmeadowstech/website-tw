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

variable "hostname" {
  default = "cmeadows.tech"
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

resource "azurerm_static_site_custom_domain" "custom_domain" {
  depends_on = [ azurerm_static_site.site ]
  static_site_id  = azurerm_static_site.site.id
  domain_name     = "${var.hostname}"
  validation_type = "dns-txt-token"
}

resource "azurerm_dns_txt_record" "txt_record" {
  name                = "@"
  zone_name           = "${var.hostname}"
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  record {
    value = azurerm_static_site_custom_domain.custom_domain.validation_token
  }
}

resource "azurerm_dns_a_record" "a_record" {
  depends_on = [ azurerm_static_site.site ]
  name                = "@"
  zone_name           = "cmeadows.tech"
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  target_resource_id  = azurerm_static_site.site.id
}

# Make sure to mark this as sensitive if running this somewhere public, such as GitHub

output "site_api_token" {
  value = azurerm_static_site.site.api_key
}