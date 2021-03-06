variable "vm_name" {}

variable "additional_disk_size_gb" {
  default = 0
}

variable "resource_group" {}

variable "location" {
  default = "UK South"
}

variable "avset_id" {}
variable "ssh_key" {}
variable "storage_account" {}
variable "diagnostics_storage_account" {}

variable "instance_count" {
  default = 1
}

variable "vm_size" {
  default = "Standard_D2_v2"
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

variable "azure_subscription_id" {}
variable "resource_group_name" {}
variable "vnet" {}
variable "subnet" {}

variable "port" {}
variable "admin_username" {}