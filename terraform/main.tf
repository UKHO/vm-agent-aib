terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "aib-rg" {
  name     = var.vnetRgName
  location = var.location_id
}

resource "azurerm_user_assigned_identity" "identity" {
  resource_group_name = azurerm_resource_group.aib-rg.name
  location = azurerm_resource_group.aib-rg.location

  name = "aib-identity"
}

resource "azurerm_role_assignment" "aib-subscription-contributor" {
  scope = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id = azurerm_user_assigned_identity.identity.principal_id
}

resource "azurerm_virtual_network" "aib-vnet" {
  resource_group_name = azurerm_resource_group.aib-rg.name
  name                = var.vnetName
  address_space       = ["10.1.2.0/24"]
  location            = azurerm_resource_group.aib-rg.location
}

resource "azurerm_subnet" "aib-subnet" {
  name                                           = var.subnetName
  resource_group_name                            = azurerm_resource_group.aib-rg.name
  virtual_network_name                           = azurerm_virtual_network.aib-vnet.name
  enforce_private_link_service_network_policies  = true
  address_prefixes                               = ["10.1.2.0/25"]
}

resource "azurerm_network_security_group" "aib-nsg" {
  name                = "m-az-aib-nsg"
  location            = azurerm_resource_group.aib-rg.location
  resource_group_name = azurerm_resource_group.aib-rg.name

  security_rule {
    name                       = "aib-access-rule"
    direction                  = "Inbound"
    access                     = "Allow"
    priority                   = 400
    source_address_prefix      = "AzureLoadBalancer"
    source_port_range          = "*"
    destination_address_prefix = "VirtualNetwork"
    destination_port_range     = "60000-60001"
    protocol                   = "Tcp"
  }
}

resource "azurerm_subnet_network_security_group_association" "aib-subnet-assocation" {
  subnet_id                 = azurerm_subnet.aib-subnet.id
  network_security_group_id = azurerm_network_security_group.aib-nsg.id
}
