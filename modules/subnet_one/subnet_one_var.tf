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

# NSG Security Rule Variables #

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
    description = "value"
    type = string
}
variable "access" {
    description = "value"
    type = string
}

# Availability Set Variables #

variable "availability_set_name" {
    type = string
}

# Virtual Machine Variables #

variable "admin_username" {
    type = string
}

variable "vm_size" {
    type = string
}

variable "vm_count" {
    type = number
}

variable "caching" {
    type = string
}

variable "storage_account_type" {
    type = string
}

variable "disk_size_gb" {
    type = number
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

variable "ip_configuration_name" {
    type = string
}

variable "private_ip_address_allocation" {
    type = string
}

# General Variable #

variable "overall_location" {
    type = string
}