variable "vm_name" {}

variable "additional_disk_size_gb" {
  default = 0
}

variable "resource_group" {}

variable "location" {
  default = "uksouth"
}

variable "subnet_id" {}

variable "ssh_key" {}

variable "instance_count" {
  default = 1
}

variable "vm_size" {
  default = "Standard_DS2_v2"
}

#TAGS
variable "product" {}

variable "env" {}

variable "tier" {
  default = "UNSET"
}

variable "ansible" {
  default = "true"
}

variable "role" {
  default = "UNSET"
}

variable "storageacc_prefix" {}

variable "data_disk_size" {
  default = "30"
}

variable "delete_os_disk_on_termination" {
  default = "true"
}

variable "delete_data_disks_on_termination" {
  default = "true"
}

variable "resource_group_name" {}
variable "vnet" {}

variable "admin_username" {}

variable "port" {}
variable "azure_subscription_id" {}
