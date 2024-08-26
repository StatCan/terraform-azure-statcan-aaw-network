terraform {
  required_providers {
    # See https://github.com/StatCan/aaw-private/issues/184#issuecomment-2310744303 for details
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "< 4.0"
    }
  }
}
