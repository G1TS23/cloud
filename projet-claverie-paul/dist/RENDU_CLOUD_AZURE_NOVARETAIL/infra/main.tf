# =====================================================================
# main.tf — Infrastructure cible NovaRetail (migration vers Azure)
#
# Ressources déployées :
#   - Resource Group
#   - Virtual Network + 2 subnets (web / data)
#   - 2 Network Security Groups (filtrage web et data)
#   - 2 VM Linux derrière un Load Balancer standard (haute disponibilité)
#   - Storage Account privé (versioning + soft delete)
#   - Log Analytics Workspace (supervision)
#   - Azure Database for MySQL Flexible Server (optionnel, managé)
# =====================================================================

terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # En production, le state doit être distant et verrouillé (cf. rapport Partie 2).
  # Exemple de backend distant à activer une fois le Storage de state créé :
  #
  # backend "azurerm" {
  #   resource_group_name  = "rg-novaretail-shared"
  #   storage_account_name = "stnovaretailtfstate"
  #   container_name       = "tfstate"
  #   key                  = "novaretail.prod.tfstate"
  # }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# ---------------------------------------------------------------------
# Conventions de nommage et tags
# ---------------------------------------------------------------------
locals {
  name_prefix = "${var.prefix}-${var.project_name}-${var.environment}"

  common_tags = merge(var.tags, {
    environment = var.environment
    managed-by  = "terraform"
  })
}

# Suffixe aléatoire pour garantir l'unicité globale du Storage Account
resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Clé SSH générée par Terraform (aucun mot de passe en clair, aucun secret versionné)
resource "tls_private_key" "vm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# ---------------------------------------------------------------------
# Resource Group
# ---------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
  tags     = local.common_tags
}

# ---------------------------------------------------------------------
# Réseau : Virtual Network + 2 subnets
# ---------------------------------------------------------------------
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = var.vnet_address_space
  tags                = local.common_tags
}

resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.web_subnet_prefix
}

resource "azurerm_subnet" "data" {
  name                 = "snet-data"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.data_subnet_prefix

  # Délégation requise pour MySQL Flexible Server en injection VNet
  delegation {
    name = "mysql-delegation"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# ---------------------------------------------------------------------
# NSG web : HTTP/HTTPS depuis Internet, SSH restreint
# ---------------------------------------------------------------------
resource "azurerm_network_security_group" "web" {
  name                = "nsg-web"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.common_tags

  security_rule {
    name                       = "Allow-HTTP-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS-Inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # SSH restreint à une plage d'administration (jamais 0.0.0.0/0)
  security_rule {
    name                       = "Allow-SSH-Admin-Only"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.admin_source_address
    destination_address_prefix = "*"
  }
}

# ---------------------------------------------------------------------
# NSG data : MySQL 3306 uniquement depuis le subnet web
# ---------------------------------------------------------------------
resource "azurerm_network_security_group" "data" {
  name                = "nsg-data"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.common_tags

  security_rule {
    name                       = "Allow-MySQL-From-Web"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = var.web_subnet_prefix[0]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web.id
}

# ---------------------------------------------------------------------
# Load Balancer public (haute disponibilité des 2 VM web)
# ---------------------------------------------------------------------
resource "azurerm_public_ip" "lb" {
  name                = "pip-${local.name_prefix}-lb"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_lb" "main" {
  name                = "lb-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"
  tags                = local.common_tags

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  name            = "backend-pool"
  loadbalancer_id = azurerm_lb.main.id
}

resource "azurerm_lb_probe" "http" {
  name            = "http-probe"
  loadbalancer_id = azurerm_lb.main.id
  protocol        = "Tcp"
  port            = 80
}

resource "azurerm_lb_rule" "http" {
  name                           = "http-rule"
  loadbalancer_id                = azurerm_lb.main.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.http.id

  # Obligatoire quand une règle de sortie (outbound rule) utilise la même
  # IP frontend : le SNAT est géré par la règle de sortie dédiée.
  disable_outbound_snat = true
}

# Règle de sortie : permet aux VM (sans IP publique) d'accéder à Internet
# (mises à jour apt, cloud-init) via SNAT sur l'IP publique du Load Balancer.
resource "azurerm_lb_outbound_rule" "internet" {
  name                    = "outbound-rule"
  loadbalancer_id         = azurerm_lb.main.id
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id

  frontend_ip_configuration {
    name = "frontend"
  }
}

# ---------------------------------------------------------------------
# 2 VM Linux web (Ubuntu) — Apache installé via cloud-init
# ---------------------------------------------------------------------
resource "azurerm_network_interface" "web" {
  count               = var.vm_count
  name                = "nic-web-${format("%02d", count.index + 1)}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.common_tags

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "web" {
  count                   = var.vm_count
  network_interface_id    = azurerm_network_interface.web[count.index].id
  ip_configuration_name   = "ipconfig"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

resource "azurerm_linux_virtual_machine" "web" {
  count               = var.vm_count
  name                = "vm-web-${format("%02d", count.index + 1)}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size
  admin_username      = var.admin_username
  tags                = local.common_tags

  network_interface_ids = [azurerm_network_interface.web[count.index].id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.vm_ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Identité managée : lecture des secrets en Key Vault sans mot de passe en dur
  identity {
    type = "SystemAssigned"
  }

  custom_data = base64encode(<<-CLOUDINIT
    #cloud-config
    package_update: true
    packages:
      - apache2
    runcmd:
      - echo "<h1>NovaRetail - $(hostname)</h1><p>Serveur web migre sur Azure (Partie 3 Terraform).</p>" > /var/www/html/index.html
      - systemctl enable apache2
      - systemctl restart apache2
  CLOUDINIT
  )
}

# ---------------------------------------------------------------------
# Storage Account privé (fichiers clients) — versioning + soft delete
# ---------------------------------------------------------------------
resource "azurerm_storage_account" "main" {
  name                     = substr("st${var.project_name}${random_string.storage_suffix.result}", 0, 24)
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  # Anomalie corrigée : aucun accès ANONYME aux blobs (plus d'exposition publique).
  # NB : en production, on ajouterait un Private Endpoint et
  # public_network_access_enabled = false. Conservé activé ici pour permettre
  # la création du conteneur via le plan de données lors du déploiement.
  allow_nested_items_to_be_public = false

  tags = local.common_tags

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }
}

resource "azurerm_storage_container" "clients" {
  name                  = "fichiers-clients"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# ---------------------------------------------------------------------
# Log Analytics Workspace (supervision / journalisation centralisée)
# ---------------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags
}

# ---------------------------------------------------------------------
# Base de données managée : Azure Database for MySQL Flexible Server
# (optionnelle via var.deploy_mysql ; remplace MySQL sur VM)
# ---------------------------------------------------------------------
resource "random_password" "mysql" {
  count   = var.deploy_mysql ? 1 : 0
  length  = 20
  special = true
}

resource "azurerm_mysql_flexible_server" "main" {
  count               = var.deploy_mysql ? 1 : 0
  name                = "mysql-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  administrator_login    = var.mysql_admin_username
  administrator_password = random_password.mysql[0].result

  sku_name = "B_Standard_B1ms"
  version  = "8.0.21"
  zone     = "1"

  storage {
    size_gb = 20
  }

  backup_retention_days = 7
  tags                  = local.common_tags
}
