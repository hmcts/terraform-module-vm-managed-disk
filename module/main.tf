data "template_file" "server_name" {
  template = "$${prefix}${format("%02d", count.index + 1)}"

  count = "${var.instance_count}"

  vars {
    prefix = "${var.vm_name}"
  }
}

data "template_file" "storageacc_prefix" {
  template = "$${prefix}${format("%02d", count.index + 1)}"

  count = "${var.instance_count}"

  vars {
    prefix = "${var.storageacc_prefix}"
  }
}

resource "random_string" "password" {
  length  = 20
  special = true
}

# Create Networking
resource "azurerm_network_interface" "reform-nonprod" {
  count               = "${var.instance_count}"
  name                = "${element(data.template_file.server_name.*.rendered, count.index)}-NIC"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  ip_configuration {
    name                          = "${element(data.template_file.server_name.*.rendered, count.index)}-NIC"
    subnet_id                     = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${var.vnet}/subnets/${var.subnet}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_storage_account" "storageacc" {
  count               = "${var.instance_count}"
  name                = "${element(data.template_file.storageacc_prefix.*.rendered, count.index)}os"
  resource_group_name = "${var.resource_group}"

  lifecycle {
    ignore_changes = ["name"]
  }

  location                 = "uksouth"
  account_tier             = "Premium"
  account_replication_type = "LRS"

  tags {
    env     = "${var.env}"
    product = "${var.product}"
  }
}

resource "azurerm_storage_account" "bootdiagnostics" {
  count               = "${var.instance_count}"
  name                = "${element(data.template_file.storageacc_prefix.*.rendered, count.index)}boot"
  resource_group_name = "${var.resource_group}"

  lifecycle {
    ignore_changes = ["name"]
  }

  location                 = "uksouth"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags {
    env     = "${var.env}"
    product = "${var.product}"
  }
}

# Availability Set
resource "azurerm_availability_set" "AvSet" {
  name                        = "${var.vm_name}AVset"
  location                    = "uksouth"
  resource_group_name         = "${var.resource_group}"
  managed                     = "true"
  platform_fault_domain_count = 2

  tags {
    env     = "${var.env}"
    product = "${var.product}"
  }
}

resource "azurerm_virtual_machine" "reform-nonprod" {
  count                 = "${var.instance_count}"
  name                  = "${element(data.template_file.server_name.*.rendered, count.index)}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group}"
  network_interface_ids = ["${element(azurerm_network_interface.reform-nonprod.*.id, count.index)}"]
  vm_size               = "${var.vm_size}"
  availability_set_id   = "${azurerm_availability_set.AvSet.id}"
  depends_on            = ["azurerm_storage_account.bootdiagnostics", "azurerm_storage_account.storageacc"]

  delete_os_disk_on_termination    = "${var.delete_os_disk_on_termination}"
  delete_data_disks_on_termination = "${var.delete_data_disks_on_termination}"

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.3"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${element(data.template_file.server_name.*.rendered, count.index)}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  # Optional data disks
  storage_data_disk {
    name              = "${element(data.template_file.server_name.*.rendered, count.index)}-datadisk"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "${var.data_disk_size}"
  }

  os_profile {
    computer_name  = "${element(data.template_file.server_name.*.rendered, count.index)}"
    admin_username = "${var.admin_username}"
    admin_password = "${random_string.password.result}"
  }

  lifecycle {
    ignore_changes = ["os_profile"]
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${var.ssh_key}"
    }
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "https://${element(data.template_file.storageacc_prefix.*.rendered, count.index)}boot.blob.core.windows.net/"
  }

  lifecycle {
    ignore_changes = ["boot_diagnostics"]
  }

  tags {
    type      = "vm"
    product   = "${var.product}"
    env       = "${var.env}"
    tier      = "${var.tier}"
    ansible   = "${var.ansible}"
    terraform = "true"
    role      = "${var.role}"
  }
}

resource "azurerm_virtual_machine_extension" "script" {
  count                = "${var.instance_count}"
  name                 = "${element(data.template_file.server_name.*.rendered, count.index)}"
  location             = "${var.location}"
  resource_group_name  = "${var.resource_group}"
  virtual_machine_name = "${element(data.template_file.server_name.*.rendered, count.index)}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  depends_on           = ["azurerm_virtual_machine.reform-nonprod"]

  settings = <<SETTINGS
    {
        "commandToExecute": "iptables -t nat -A PREROUTING -p tcp --dport ${var.port} -j REDIRECT --to-ports 22; iptables-save > /etc/sysconfig/iptables"
    }
SETTINGS
}
