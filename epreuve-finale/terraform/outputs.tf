output "resource_group_name" {
  description = "Nom du groupe de ressources cree."
  value       = azurerm_resource_group.main.name
}

output "load_balancer_public_ip" {
  description = "Adresse IP publique du point d'entree web."
  value       = azurerm_public_ip.lb.ip_address
}

output "web_vm_public_ips" {
  description = "Adresses IP publiques des machines web, utiles pour l'administration."
  value       = azurerm_public_ip.web[*].ip_address
}

output "storage_account_name" {
  description = "Nom du compte de stockage des documents."
  value       = azurerm_storage_account.docs.name
}

output "mysql_server_fqdn" {
  description = "Nom de domaine prive du serveur MySQL managee."
  value       = azurerm_mysql_flexible_server.main.fqdn
}
