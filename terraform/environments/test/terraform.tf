terraform {
  required_version = ">= 1.6"

  backend "azurerm" {
    key = "test.app.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
}