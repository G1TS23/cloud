# =====================================================================
# variables.tf — Paramètres d'entrée du projet NovaRetail
# Toutes les valeurs réglables du déploiement sont centralisées ici.
# =====================================================================

variable "project_name" {
  description = "Nom du projet, utilisé dans le nommage des ressources."
  type        = string
  default     = "novaretail"
}

variable "location" {
  description = "Région Azure de déploiement."
  type        = string
  default     = "swedencentral"
}

variable "environment" {
  description = "Environnement cible (dev, prod, ...)."
  type        = string
  default     = "prod"
}

variable "prefix" {
  description = "Préfixe de nommage appliqué à toutes les ressources."
  type        = string
  default     = "nr"
}

variable "vnet_address_space" {
  description = "Plage d'adressage du Virtual Network (CIDR)."
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "web_subnet_prefix" {
  description = "CIDR du subnet web (couche applicative)."
  type        = list(string)
  default     = ["10.10.1.0/24"]
}

variable "data_subnet_prefix" {
  description = "CIDR du subnet data (base de données)."
  type        = list(string)
  default     = ["10.10.2.0/24"]
}

variable "vm_size" {
  description = "Taille des machines virtuelles Linux (D2s_v3 : disponible à swedencentral, la famille B y est en restriction de capacité)."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vm_count" {
  description = "Nombre de VM web à déployer derrière le Load Balancer."
  type        = number
  default     = 2
}

variable "admin_username" {
  description = "Nom de l'utilisateur administrateur des VM Linux."
  type        = string
  default     = "azureadmin"
}

variable "admin_source_address" {
  description = "Plage d'IP autorisée à se connecter en SSH (jamais 0.0.0.0/0 en production)."
  type        = string
  default     = "VirtualNetwork"
}

variable "deploy_mysql" {
  description = "Déployer la base de données managée Azure Database for MySQL Flexible Server."
  type        = bool
  default     = true
}

variable "mysql_admin_username" {
  description = "Nom de l'administrateur de la base MySQL managée."
  type        = string
  default     = "mysqladmin"
}

variable "tags" {
  description = "Tags communs appliqués à toutes les ressources (gouvernance + FinOps)."
  type        = map(string)
  default = {
    application = "novaretail"
    owner       = "dsi.ops"
    cost-center = "cc-novaretail"
    criticality = "high"
    review-date = "2026-12-31"
  }
}
