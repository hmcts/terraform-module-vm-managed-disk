terraform {
  backend "azurerm" {

    # storage_account_name - subscription ID, with '-' removed, then only the first 24 chars
    storage_account_name = "6aff0bdf7c1248508f7e7dd4"
    container_name       = "statefiles"
    resource_group_name  = "tfStateRG"
    key                  = "sandbox-tf-module-vm-managed-disk.tf"
  }
}
