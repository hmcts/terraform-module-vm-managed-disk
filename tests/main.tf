# Here is the code which actually creates a resources using the module

module "sandbox-test-vm-managed-disk" {
  source            = "../module"
  vm_name           = "sandbox-test-vm-managed-disk"
  resource_group    = "${azurerm_resource_group.test.name}"
  subnet_id         = "${azurerm_subnet.test.id}"
  vm_size           = "Standard_B1s"
  env               = "sandbox"
  product           = "sandbox"
  instance_count    = 1
  storageacc_prefix = "sandboxtstmodmd"
  data_disk_size    = "30"
}
