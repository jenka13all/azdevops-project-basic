terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">=0.2.1"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.14.0"

    }

    azuread = {
      source = "hashicorp/azuread"
      version = "~> 2.26.1"
    }

  }
  backend "local" {
    path = "../tfstate/test_framework.tfstate"
  }
}