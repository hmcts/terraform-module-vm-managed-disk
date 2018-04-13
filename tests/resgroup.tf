resource "azurerm_resource_group" "test" {
  name     = "${var.test_name}-rg"
  location = "${var.azure_region}"

  tags {
    environment = "sandbox"
  }
}
