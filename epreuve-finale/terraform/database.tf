resource "azurerm_private_dns_zone" "mysql" {
  name                = "${var.project}.private.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "mysql-dns-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = azurerm_virtual_network.main.id
  tags                  = local.common_tags
}

resource "azurerm_mysql_flexible_server" "main" {
  name                   = "mysql-${local.prefix}-${random_string.suffix.result}"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  administrator_login    = var.mysql_admin_login
  administrator_password = var.mysql_admin_password
  sku_name               = var.mysql_sku_name
  version                = "8.0.21"

  delegated_subnet_id = azurerm_subnet.data.id
  private_dns_zone_id = azurerm_private_dns_zone.mysql.id

  storage {
    size_gb = 20
  }

  backup_retention_days = 7
  tags                  = local.common_tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql]
}

resource "azurerm_mysql_flexible_database" "app" {
  name                = "novaretail"
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}
