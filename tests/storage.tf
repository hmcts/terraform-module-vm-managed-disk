resource "azurerm_storage_account" "test" {
  name                     = "sandboxtfmodulemandisk"
  resource_group_name      = "${azurerm_resource_group.test.name}"
  location                 = "${var.azure_region}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags {
    environment = "sandbox"
  }
}
