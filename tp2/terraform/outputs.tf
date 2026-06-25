output "resource_group_name" {
  description = "Nom du Resource Group cree"
  value       = azurerm_resource_group.main.name
}

output "load_balancer_public_ip" {
  description = "Adresse IP publique du Load Balancer (point d'entree de l'application)"
  value       = azurerm_public_ip.lb.ip_address
}

output "web_vm_public_ips" {
  description = "Adresses IP publiques directes des deux VM web"
  value       = azurerm_public_ip.web[*].ip_address
}

output "storage_account_name" {
  description = "Nom du Storage Account des documents"
  value       = azurerm_storage_account.docs.name
}
