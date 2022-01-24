resource "azurerm_subnet" "subnet_one" {
    name = var.subnet_name
    resource_group_name = var.resource_group_name
    virtual_network_name = var.virtual_network_name
    service_endpoints = var.service_endpoints
    address_prefixes = var.address_prefixes
}

resource "azurerm_network_security_group" "nsg" {
    count = var.vm_count
    name = "NSG_Subnet_One${count.index}"
    resource_group_name = var.resource_group_name
    location = var.overall_location
}

resource "azurerm_network_security_rule" "nsg_rule" {
    count = var.vm_count
    resource_group_name = var.resource_group_name
    network_security_group_name = element(azurerm_network_security_group.nsg.*.name, count.index)
    name = "SSH_VM_NSG_Rule${count.index}"
    protocol = var.protocol
    source_port_range = var.source_port_range
    source_address_prefix = var.source_address_prefix
    destination_port_range = var.destination_port_range
    destination_address_prefix = var.destination_address_prefix
    priority = var.priority
    direction = var.direction
    access = var.access
}

resource "azurerm_public_ip" "public_ip" {
    count = var.vm_count
    name = "access_public_ip_Subnet_One${count.index}"
    resource_group_name = var.resource_group_name
    location = var.overall_location
    allocation_method = "Dynamic"
}


resource "azurerm_availability_set" "availability_set" {
    name = var.availability_set_name
    resource_group_name = var.resource_group_name
    location = var.overall_location
}

resource "azurerm_linux_virtual_machine" "linux_virtual_machine" {
    depends_on = [azurerm_network_interface.network_interface]
    name = "LinuxVMSubnetOne${count.index}"
    admin_username = var.admin_username
    admin_ssh_key {
        username   = var.admin_username
        public_key = file("~/.ssh/id_rsa.pub")
    }
    resource_group_name = var.resource_group_name
    location = var.overall_location
    network_interface_ids = [element(azurerm_network_interface.network_interface.*.id, count.index)]
    os_disk {
        caching = var.caching
        storage_account_type = var.storage_account_type
        disk_size_gb = var.disk_size_gb
    }
    size = var.vm_size
    availability_set_id = azurerm_availability_set.availability_set.id
    source_image_reference {
        publisher = var.image_publisher
        offer = var.image_offer
        sku = var.image_sku
        version = var.image_version
    }
    count = var.vm_count

}

resource "azurerm_network_interface" "network_interface" {
    count = var.vm_count
    name = "networkinterfacesubone${count.index}"
    ip_configuration {
        name = var.ip_configuration_name
        subnet_id = azurerm_subnet.subnet_one.id
        private_ip_address_allocation = var.private_ip_address_allocation
        public_ip_address_id = element(azurerm_public_ip.public_ip.*.id, count.index)
    }
    location = var.overall_location
    resource_group_name = var.resource_group_name
}

resource "azurerm_network_interface_security_group_association" "network_interface_nsg_assoc" {
    count = var.vm_count
    network_interface_id = element(azurerm_network_interface.network_interface.*.id, count.index)
    network_security_group_id = element(azurerm_network_security_group.nsg.*.id, count.index)
}