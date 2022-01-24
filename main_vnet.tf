resource "azurerm_virtual_network" "virtual_network" {
    name = "CTC_VNet"
    resource_group_name = azurerm_resource_group.resource_group.name
    address_space = ["10.0.0.0/16"]
    location = var.overall_location
}

resource "azurerm_lb" "load_balancer" {
    name = "CTC_LoadBalancer"
    resource_group_name = azurerm_resource_group.resource_group.name
    location = var.overall_location
    frontend_ip_configuration {
        name = "alb_ip_config"
        public_ip_address_id = azurerm_public_ip.public_ip.id
    }
}

resource "azurerm_public_ip" "public_ip" {
    name = "alb_public_ip"
    location = var.overall_location
    resource_group_name = azurerm_resource_group.resource_group.name
    allocation_method = "Dynamic"
}

resource "azurerm_lb_nat_rule" "nat_rule" {
    resource_group_name = azurerm_resource_group.resource_group.name
    loadbalancer_id = azurerm_lb.load_balancer.id
    name = "VM_Subnet_Three_Connect"
    protocol = "Tcp"
    frontend_port = 80
    backend_port = 22
    frontend_ip_configuration_name = azurerm_lb.load_balancer.frontend_ip_configuration[0].name
}

resource "azurerm_lb_backend_address_pool" "backend_address_pool" {
    loadbalancer_id = azurerm_lb.load_balancer.id
    name = "Backend_Address_Pool_ALB"
}

module "subnet_components_one" {
    source = "./modules/subnet_one/"

    overall_location = var.overall_location

    # Subnet # 
    subnet_name = "Sub1"
    resource_group_name = azurerm_resource_group.resource_group.name
    virtual_network_name = azurerm_virtual_network.virtual_network.name
    service_endpoints = ["Microsoft.Storage"]
    address_prefixes = ["10.0.0.0/24"]

    # NSG Security Rule #
    protocol = "TCP"
    source_port_range = "*"
    source_address_prefix = "*"
    destination_port_range = "22"
    destination_address_prefix = "*"
    priority = 100
    direction = "Inbound"
    access = "Allow"

    # Availability Set #
    availability_set_name = "Subnet1_Availability_Set"

    # VM #
    vm_count = 2
    admin_username = "azureuser"
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb = 256
    
    vm_size = "Standard_DS1_v2"

    image_publisher = "RedHat"
    image_offer = "RHEL"
    image_sku = "8.1"
    image_version = "latest"

    # Network Interface #
    ip_configuration_name = "Network_Interface_Subnet1"
    private_ip_address_allocation = "Dynamic"
    
}

resource "azurerm_subnet" "subnet_two" {
    name = "Sub2"
    resource_group_name = azurerm_resource_group.resource_group.name
    virtual_network_name = azurerm_virtual_network.virtual_network.name
    service_endpoints = ["Microsoft.Storage"]
    address_prefixes = ["10.0.1.0/24"]
}

module "subnet_components_three" {
    source = "./modules/subnet_three/"

    overall_location = var.overall_location

    # Subnet # 
    subnet_name = "Sub3"
    resource_group_name = azurerm_resource_group.resource_group.name
    virtual_network_name = azurerm_virtual_network.virtual_network.name
    service_endpoints = ["Microsoft.Storage"]
    address_prefixes = ["10.0.2.0/24"]

    # NSG #
    nsg_name = "Subnet3_VM_NSG"
   
    # NSG Security Rule #
    name = "ALB_VM_NSG_Three_Rule"
    protocol = "TCP"
    source_port_range = "*"
    source_address_prefix = "*"
    destination_port_range = "80"
    destination_address_prefix = "*"
    priority = 102
    direction = "Inbound"
    access = "Allow"

    # VM #
    admin_username = "azureuser"
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
    
    vm_size = "Standard_DS1_v2"
   
    image_publisher = "RedHat"
    image_offer = "RHEL"
    image_sku = "7.4"
    image_version = "latest"
    
    # Network Interface #
    network_interface_name = "CTC_Network_Interface_VM_Three"
    ip_configuration_name = "Network_Interface_Subnet3"
    private_ip_address_allocation = "Dynamic"

    # Network Interface NAT Rule Association #
    nat_rule_id = azurerm_lb_nat_rule.nat_rule.id
}

resource "azurerm_subnet" "subnet_four" {
    name = "Sub4"
    resource_group_name = azurerm_resource_group.resource_group.name
    virtual_network_name = azurerm_virtual_network.virtual_network.name
    service_endpoints = ["Microsoft.Storage"]
    address_prefixes = ["10.0.3.0/24"]
}

resource "azurerm_storage_account" "storage_account" {

    depends_on = [module.subnet_components_one, module.subnet_components_three]

    name = "ctcstorageaccountmain"
    resource_group_name = azurerm_resource_group.resource_group.name
    location = var.overall_location
    account_tier = "Standard"
    account_replication_type = "LRS"

    network_rules {
      default_action = "Deny"
      virtual_network_subnet_ids = [module.subnet_components_one.subnet_id_value, azurerm_subnet.subnet_two.id, module.subnet_components_three.subnet_id_value, azurerm_subnet.subnet_four.id]
    }
}