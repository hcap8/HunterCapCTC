resource "azurerm_subnet" "subnet_three" {
    name = var.subnet_name
    resource_group_name = var.resource_group_name
    virtual_network_name = var.virtual_network_name
    service_endpoints = var.service_endpoints
    address_prefixes = var.address_prefixes
}

resource "azurerm_network_security_group" "nsg" {
    name = var.nsg_name
    resource_group_name = var.resource_group_name
    location = var.overall_location
}

resource "azurerm_network_security_rule" "nsg_rule_ssh" {
    resource_group_name = var.resource_group_name
    network_security_group_name = azurerm_network_security_group.nsg.name
    name = var.name
    protocol = var.protocol
    source_port_range = var.source_port_range
    source_address_prefix = var.source_address_prefix
    destination_port_range = var.destination_port_range
    destination_address_prefix = var.destination_address_prefix
    priority = var.priority
    direction = var.direction
    access = var.access
}

resource "azurerm_network_security_rule" "nsg_rule_open" {
    resource_group_name = var.resource_group_name
    network_security_group_name = azurerm_network_security_group.nsg.name
    name = var.name
    protocol = var.protocol
    source_port_range = var.source_port_range
    source_address_prefix = var.source_address_prefix
    destination_port_range = var.destination_port_range
    destination_address_prefix = var.destination_address_prefix
    priority = var.priority
    direction = var.direction
    access = var.access
}

resource "azurerm_linux_virtual_machine" "linux_virtual_machine" {
    name = "LinuxVMSubnetThree"
    admin_username = var.admin_username
    admin_ssh_key {
        username   = var.admin_username
        public_key = file("~/.ssh/id_rsa.pub")
    }
    resource_group_name = var.resource_group_name
    location = var.overall_location
    network_interface_ids = [azurerm_network_interface.network_interface.id]
    os_disk {
        caching = var.caching
        storage_account_type = var.storage_account_type
    }
    size = var.vm_size
    source_image_reference {
        publisher = var.image_publisher
        offer = var.image_offer
        sku = var.image_sku
        version = var.image_version
    }
    
    provisioner "remote-exec" {
        connection {
            type = "ssh"
            user = "azureuser"
            host = "${azurerm_linux_virtual_machine.linux_virtual_machine.public_ip_address}"
            port = 22
            private_key = file("~/.ssh/id_rsa")
        }

        inline = [
                "sudo yum install httpd -y",
                "sudo systemctl enable httpd.service",
                "sudo systemctl start httpd.service"]
        }
}

resource "azurerm_network_security_rule" "NSG_rule_ssh" {
    resource_group_name = var.resource_group_name
    network_security_group_name = azurerm_network_security_group.nsg.name
    name = "ALB_VM_NSG_Three_RuleSSH"
    protocol = "TCP"
    source_port_range = "*"
    source_address_prefix = "*"
    destination_port_range = "22"
    destination_address_prefix = "*"
    priority = 103
    direction = "Inbound"
    access = "Allow"
}

resource "azurerm_public_ip" "access_public_ip" {
    name = "access_public_ip_Subnet_Three"
    resource_group_name = var.resource_group_name
    location = var.overall_location
    allocation_method = "Dynamic"
}

resource "azurerm_network_interface" "network_interface" {
    name = var.network_interface_name
    ip_configuration {
        name = var.ip_configuration_name
        subnet_id = azurerm_subnet.subnet_three.id
        private_ip_address_allocation = var.private_ip_address_allocation
        public_ip_address_id = azurerm_public_ip.access_public_ip.id
    }
    location = var.overall_location
    resource_group_name = var.resource_group_name
}

resource "azurerm_network_interface_security_group_association" "network_interface_nsg_assoc" {
    network_interface_id = azurerm_network_interface.network_interface.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface_nat_rule_association" "nat_rule_network_interface_assoc" {
    network_interface_id = azurerm_network_interface.network_interface.id
    ip_configuration_name = var.ip_configuration_name
    nat_rule_id = var.nat_rule_id
}