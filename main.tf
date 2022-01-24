terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = ">=2.93.0"
        }
    }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_group" {
    name = "CTC_Resource_Group"
    location = var.overall_location
}