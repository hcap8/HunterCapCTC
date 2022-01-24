# Subnet Variables #

variable "subnet_name" {
    type = string
}

variable "resource_group_name" {
    type = string
}

variable "virtual_network_name" {
    type = string
}

variable "service_endpoints" {
    type = list(string)
}

variable "address_prefixes" {
    type = list(string)
}

# Network Security Group Variables #

variable "nsg_name" {
    type = string
}

# NSG Security Rule Variables #

variable "name" {
    type = string
}
variable "protocol" {
    type = string
}
variable "source_port_range" {
    type = string
}
variable "source_address_prefix" {
    type = string
}
variable "destination_port_range" {
    type = string
}
variable "destination_address_prefix" {
    type = string
}
variable "priority" {
    type = number
}
variable "direction" {
    type = string
}
variable "access" {
    type = string
}

# Virtual Machine Variables #

variable "admin_username" {
    type = string
}

variable "vm_size" {
    type = string
}

variable "caching" {
    type = string
}

variable "storage_account_type" {
    type = string
}

variable "image_publisher" {
    type = string
}

variable "image_offer" {
    type = string
}

variable "image_sku" {
    type = string
}

variable "image_version" {
    type = string
}

# Network Interface Variables #

variable "network_interface_name" {
    type = string
}

variable "ip_configuration_name" {
    type = string
}

variable "private_ip_address_allocation" {
    type = string
}

# Network Interface NAT Rule Association Variables #

variable "nat_rule_id" {
    type = string
}

# General Variable #

variable "overall_location" {
    type = string
}
