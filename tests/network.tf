resource "azurerm_virtual_network" "test" {
  name                = "${var.test_name}-vnet"
  address_space       = ["10.11.0.0/16"]
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  tags {
    environment = "sandbox"
  }
}

resource "azurerm_subnet" "test" {
  name                 = "${var.test_name}-subnet"
  resource_group_name  = "${azurerm_resource_group.test.name}"
  virtual_network_name = "${azurerm_virtual_network.test.name}"
  address_prefix       = "10.11.1.0/24"
}
