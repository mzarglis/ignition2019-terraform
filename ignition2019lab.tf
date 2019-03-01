##############################################
################ VARIABLES ###################
##############################################
variable "region"             {}
variable "subscription_id"    {}
variable "small_instance"     {}
variable "large_instance"     {}


# Configure the Microsoft Azure Provider
provider "azurerm" {
    subscription_id = "${var.subscription_id}"
}


# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "igition2019lab" {
    name     = "igition2019lab"
    location = "${var.region}"

    tags {
        environment = "igition2019lab"
    }
}
# Network Securiy Group
resource "azurerm_network_security_group" "Default_NSG" {
    name                = "Default_NSG"
    location            = "${var.region}"
    resource_group_name = "${azurerm_resource_group.igition2019lab.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "GOTnet" {
    name                = "GOTnet"
    address_space       = ["10.1.0.0/16"]
    location            = "${var.region}"
    resource_group_name = "${azurerm_resource_group.igition2019lab.name}"

    tags {
        environment = "igition2019lab"
    }
}

resource "azurerm_virtual_network" "GOTnet2" {
    name                = "GOTnet2"
    address_space       = ["10.0.0.0/14"]
    location            = "${var.region}"
    resource_group_name = "${azurerm_resource_group.igition2019lab.name}"

    tags {
        environment = "igition2019lab"
    }
}

# Create subnet
resource "azurerm_subnet" "Highgarden" {
    name                 = "Highgarden"
    resource_group_name  = "${azurerm_resource_group.igition2019lab.name}"
    virtual_network_name = "${azurerm_virtual_network.GOTnet.name}"
    address_prefix       = "10.1.0.0/24"
}

# Create subnet
resource "azurerm_subnet" "TheSevenKingdoms" {
    name                 = "TheSevenKingdoms"
    resource_group_name  = "${azurerm_resource_group.igition2019lab.name}"
    virtual_network_name = "${azurerm_virtual_network.GOTnet2.name}"
    address_prefix       = "10.2.0.0/24"
}

# Create subnet
resource "azurerm_subnet" "NorthVale" {
    name                 = "NorthVale"
    resource_group_name  = "${azurerm_resource_group.igition2019lab.name}"
    virtual_network_name = "${azurerm_virtual_network.GOTnet2.name}"
    address_prefix       = "10.3.0.0/24"
}

# Create network interface
resource "azurerm_network_interface" "DC_Highgarden_Nic" {
    name                      = "DC_Highgarden_nic"
    location                  = "${var.region}"
    resource_group_name       = "${azurerm_resource_group.igition2019lab.name}"
    network_security_group_id = "${azurerm_network_security_group.Default_NSG.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.Highgarden.id}"
        private_ip_address_allocation = "static"
        private_ip_address            = "10.1.0.10"
        public_ip_address_id          = "${azurerm_public_ip.DC_Highgarden_pub.id}"
    }
}
resource "azurerm_public_ip" "DC_Highgarden_pub" {
    name                         = "DC_Highgarden_pub"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.igition2019lab.name}"
    allocation_method            = "Static"
}

resource "azurerm_network_interface" "Client_Highgarden_Nic" {
    name                      = "Client_Highgarden_nic"
    location                  = "${var.region}"
    resource_group_name       = "${azurerm_resource_group.igition2019lab.name}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.Highgarden.id}"
        private_ip_address_allocation = "static"
        private_ip_address            = "10.1.0.254"
        public_ip_address_id          = "${azurerm_public_ip.Client_Highgarden_pub.id}"
    }
}

resource "azurerm_public_ip" "Client_Highgarden_pub" {
    name                         = "Client_Highgarden_pub"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.igition2019lab.name}"
    allocation_method            = "Static"
}

resource "azurerm_network_interface" "DC_TheSevenKingdoms_Nic" {
    name                      = "DC_TheSevenKingdoms_Nic"
    location                  = "${var.region}"
    resource_group_name       = "${azurerm_resource_group.igition2019lab.name}"
    network_security_group_id = "${azurerm_network_security_group.Default_NSG.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.TheSevenKingdoms.id}"
        private_ip_address_allocation = "static"
        private_ip_address            = "10.2.0.10"
        public_ip_address_id          = "${azurerm_public_ip.DC_TheSevenKingdoms_pub.id}"
    }
}

resource "azurerm_public_ip" "DC_TheSevenKingdoms_pub" {
    name                         = "DC_TheSevenKingdoms_pub"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.igition2019lab.name}"
    allocation_method            = "Static"
}

resource "azurerm_network_interface" "SQL_TheSevenKingdoms" {
    name                      = "SQL_TheSevenKingdoms"
    location                  = "${var.region}"
    resource_group_name       = "${azurerm_resource_group.igition2019lab.name}"
    network_security_group_id = "${azurerm_network_security_group.Default_NSG.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.TheSevenKingdoms.id}"
        private_ip_address_allocation = "static"
        private_ip_address            = "10.2.0.103"
        public_ip_address_id          = "${azurerm_public_ip.SQL_TheSevenKingdoms_pub.id}"
    }
}
resource "azurerm_public_ip" "SQL_TheSevenKingdoms_pub" {
    name                         = "SQL_TheSevenKingdoms"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.igition2019lab.name}"
    allocation_method            = "Static"
}

resource "azurerm_network_interface" "Exchange2010_TheSevenKingdoms" {
    name                      = "Exchange2010_TheSevenKingdoms"
    location                  = "${var.region}"
    resource_group_name       = "${azurerm_resource_group.igition2019lab.name}"
    network_security_group_id = "${azurerm_network_security_group.Default_NSG.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.TheSevenKingdoms.id}"
        private_ip_address_allocation = "static"
        private_ip_address            = "10.2.0.101"
        public_ip_address_id          = "${azurerm_public_ip.Exchange2010_TheSevenKingdoms_pub.id}"
    }
}
resource "azurerm_public_ip" "Exchange2010_TheSevenKingdoms_pub" {
    name                         = "Exchange2010_TheSevenKingdoms"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.igition2019lab.name}"
    allocation_method            = "Static"
}

resource "azurerm_network_interface" "Exchange2013_TheSevenKingdoms" {
    name                      = "Exchange2013_TheSevenKingdoms"
    location                  = "${var.region}"
    resource_group_name       = "${azurerm_resource_group.igition2019lab.name}"
    network_security_group_id = "${azurerm_network_security_group.Default_NSG.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.TheSevenKingdoms.id}"
        private_ip_address_allocation = "static"
        private_ip_address            = "10.2.0.100"
        public_ip_address_id          = "${azurerm_public_ip.Exchange2013_TheSevenKingdoms_pub.id}"
    }
}
resource "azurerm_public_ip" "Exchange2013_TheSevenKingdoms_pub" {
    name                         = "Exchange2013_TheSevenKingdoms"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.igition2019lab.name}"
    allocation_method            = "Static"
}

resource "azurerm_network_interface" "DC_NorthVale_Nic" {
    name                      = "DC_NorthVale"
    location                  = "${var.region}"
    resource_group_name       = "${azurerm_resource_group.igition2019lab.name}"
    network_security_group_id = "${azurerm_network_security_group.Default_NSG.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.NorthVale.id}"
        private_ip_address_allocation = "static"
        private_ip_address            = "10.3.0.10"
        public_ip_address_id          = "${azurerm_public_ip.DC_NorthVale_pub.id}"
    }
}
resource "azurerm_public_ip" "DC_NorthVale_pub" {
    name                         = "DC_NorthVale_pub"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.igition2019lab.name}"
    allocation_method            = "Static"
}

resource "azurerm_network_interface" "App_TheSevenKingdoms_Nic" {
    name                      = "App_TheSevenKingdoms_Nic"
    location                  = "${var.region}"
    resource_group_name       = "${azurerm_resource_group.igition2019lab.name}"
    network_security_group_id = "${azurerm_network_security_group.Default_NSG.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.TheSevenKingdoms.id}"
        private_ip_address_allocation = "static"
        private_ip_address            = "10.2.0.105"
        public_ip_address_id          = "${azurerm_public_ip.App_TheSevenKingdoms_pub.id}"
    }
}
resource "azurerm_public_ip" "App_TheSevenKingdoms_pub" {
    name                         = "App_TheSevenKingdoms_pub"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.igition2019lab.name}"
    allocation_method            = "Static"
}

resource "azurerm_network_interface" "SCCM_TheSevenKingdoms_Nic" {
    name                      = "SCCM_TheSevenKingdoms_Nic"
    location                  = "${var.region}"
    resource_group_name       = "${azurerm_resource_group.igition2019lab.name}"
    network_security_group_id = "${azurerm_network_security_group.Default_NSG.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.TheSevenKingdoms.id}"
        private_ip_address_allocation = "static"
        private_ip_address            = "10.2.0.102"
        public_ip_address_id          = "${azurerm_public_ip.SCCM_TheSevenKingdoms_pub.id}"
    }
}
resource "azurerm_public_ip" "SCCM_TheSevenKingdoms_pub" {
    name                         = "SCCM_TheSevenKingdoms_pub"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.igition2019lab.name}"
    allocation_method            = "Static"
}


# Create virtual machine

resource "azurerm_virtual_machine" "DC_Highgarden" {
  name                  = "DC_Highgarden"
  location              = "${var.region}"
  resource_group_name   = "${azurerm_resource_group.igition2019lab.name}"
  network_interface_ids = ["${azurerm_network_interface.DC_Highgarden_Nic.id}"]
  vm_size               = "${var.small_instance}"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "DC_Highgarden_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {

    computer_name      = "DCHighgarden"
    admin_username     = "ignition"
    admin_password     = "Ignition2019"

  }

  os_profile_windows_config {
  }

}

resource "azurerm_virtual_machine" "Client_Highgarden" {
    name                          = "Client_Highgarden"
    location                      = "${var.region}"
    resource_group_name           = "${azurerm_resource_group.igition2019lab.name}"
    network_interface_ids         = ["${azurerm_network_interface.Client_Highgarden_Nic.id}"]
    vm_size                       = "${var.small_instance}"
    delete_os_disk_on_termination = "false"

    storage_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "rs5-pro"
    version   = "latest"
  }

  storage_os_disk {
    name              = "Client_Highgarden_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name      = "ClientHighgard"
    admin_username     = "ignition"
    admin_password     = "Ignition2019"

  }

  os_profile_windows_config {
  }

}

resource "azurerm_virtual_machine" "DC_TheSevenKingdoms" {
  name                  = "DC_TheSevenKingdoms"
  location              = "${var.region}"
  resource_group_name   = "${azurerm_resource_group.igition2019lab.name}"
  network_interface_ids = ["${azurerm_network_interface.DC_TheSevenKingdoms_Nic.id}"]
  vm_size               = "${var.small_instance}"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "DC_TheSevenKingdoms_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {

    computer_name      = "DCSevenKingdom"
    admin_username     = "ignition"
    admin_password     = "Ignition2019"

  }

  os_profile_windows_config {
  }

}

resource "azurerm_virtual_machine" "SQL_TheSevenKingdoms" {
  name                  = "SQL_TheSevenKingdoms"
  location              = "${var.region}"
  resource_group_name   = "${azurerm_resource_group.igition2019lab.name}"
  network_interface_ids = ["${azurerm_network_interface.SQL_TheSevenKingdoms.id}"]
  vm_size               = "${var.small_instance}"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "SQL_TheSevenKingdoms_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {

    computer_name      = "SQLSeven"
    admin_username     = "ignition"
    admin_password     = "Ignition2019"

  }

  os_profile_windows_config {
  }

}

resource "azurerm_virtual_machine" "Exchange2010_TheSevenKingdoms" {
  name                  = "Exchange2010_TheSevenKingdoms"
  location              = "${var.region}"
  resource_group_name   = "${azurerm_resource_group.igition2019lab.name}"
  network_interface_ids = ["${azurerm_network_interface.Exchange2010_TheSevenKingdoms.id}"]
  vm_size               = "${var.small_instance}"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2012-R2-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "Exchange2010_TheSevenKingdoms_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {

    computer_name      = "Exchange10Seven"
    admin_username     = "ignition"
    admin_password     = "Ignition2019"

  }

  os_profile_windows_config {
  }

}

resource "azurerm_virtual_machine" "Exchange2013_TheSevenKingdoms" {
  name                  = "Exchange2013_TheSevenKingdoms"
  location              = "${var.region}"
  resource_group_name   = "${azurerm_resource_group.igition2019lab.name}"
  network_interface_ids = ["${azurerm_network_interface.Exchange2013_TheSevenKingdoms.id}"]
  vm_size               = "${var.small_instance}"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2012-R2-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "Exchange2013_TheSevenKingdoms_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {

    computer_name      = "Exchange13Seven"
    admin_username     = "ignition"
    admin_password     = "Ignition2019"

  }

  os_profile_windows_config {
  }

}

resource "azurerm_virtual_machine" "DC_NorthVale" {
  name                  = "DC_NorthVale"
  location              = "${var.region}"
  resource_group_name   = "${azurerm_resource_group.igition2019lab.name}"
  network_interface_ids = ["${azurerm_network_interface.DC_NorthVale_Nic.id}"]
  vm_size               = "${var.small_instance}"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "DC_NorthVale_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {

    computer_name      = "DCNorthVale"
    admin_username     = "ignition"
    admin_password     = "Ignition2019"

  }

  os_profile_windows_config {
  }

}

resource "azurerm_virtual_machine" "App_TheSevenKingdoms" {
  name                  = "App_TheSevenKingdoms"
  location              = "${var.region}"
  resource_group_name   = "${azurerm_resource_group.igition2019lab.name}"
  network_interface_ids = ["${azurerm_network_interface.App_TheSevenKingdoms_Nic.id}"]
  vm_size               = "${var.small_instance}"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "App_TheSevenKingdoms_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {

    computer_name      = "App"
    admin_username     = "ignition"
    admin_password     = "Ignition2019"

  }

  os_profile_windows_config {
  }

}

resource "azurerm_virtual_machine" "SCCM_TheSevenKingdoms" {
  name                  = "SCCM_TheSevenKingdoms"
  location              = "${var.region}"
  resource_group_name   = "${azurerm_resource_group.igition2019lab.name}"
  network_interface_ids = ["${azurerm_network_interface.SCCM_TheSevenKingdoms_Nic.id}"]
  vm_size               = "${var.large_instance}"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "SCCM_TheSevenKingdoms_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {

    computer_name      = "SCCM"
    admin_username     = "ignition"
    admin_password     = "Ignition2019"

  }

  os_profile_windows_config {
  }

}


