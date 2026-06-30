# =====================================================================
# outputs.tf — Valeurs utiles exposées après le déploiement
# =====================================================================

output "resource_group_name" {
  description = "Nom du Resource Group contenant l'infrastructure NovaRetail."
  value       = azurerm_resource_group.main.name
}

output "load_balancer_public_ip" {
  description = "Adresse IP publique du point d'entrée HTTP (Load Balancer)."
  value       = azurerm_public_ip.lb.ip_address
}

output "storage_account_name" {
  description = "Nom du Storage Account privé (fichiers clients)."
  value       = azurerm_storage_account.main.name
}

output "web_application_url" {
  description = "URL HTTP de l'application NovaRetail (point d'entrée)."
  value       = "http://${azurerm_public_ip.lb.ip_address}"
}

output "log_analytics_workspace_name" {
  description = "Nom du Log Analytics Workspace de supervision."
  value       = azurerm_log_analytics_workspace.main.name
}

output "vm_names" {
  description = "Noms des machines virtuelles web déployées."
  value       = azurerm_linux_virtual_machine.web[*].name
}

output "mysql_server_name" {
  description = "Nom du serveur MySQL Flexible managé (si déployé)."
  value       = var.deploy_mysql ? azurerm_mysql_flexible_server.main[0].name : "non déployé (deploy_mysql=false)"
}

# Clé privée SSH générée (sensible) — à récupérer via :
#   terraform output -raw ssh_private_key > novaretail_id_rsa
output "ssh_private_key" {
  description = "Clé privée SSH pour se connecter aux VM (sensible)."
  value       = tls_private_key.vm_ssh.private_key_pem
  sensitive   = true
}
