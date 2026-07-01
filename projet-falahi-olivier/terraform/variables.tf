variable "subscription_id" {
  description = "Identifiant de l'abonnement Azure de formation."
  type        = string
  default     = "cf2f8dd7-66a6-4e61-aac0-9099eb66aada"
}

variable "project" {
  description = "Nom court de l'application, utilise dans le nommage des ressources."
  type        = string
  default     = "novaretail"
}

variable "environment" {
  description = "Nom de l'environnement, par exemple prod ou dev."
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Region Azure cible."
  type        = string
  default     = "swedencentral"
}

variable "vnet_address_space" {
  description = "Plage d'adressage du reseau virtuel."
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "web_subnet_prefix" {
  description = "Plage du subnet applicatif web."
  type        = list(string)
  default     = ["10.20.1.0/24"]
}

variable "data_subnet_prefix" {
  description = "Plage du subnet de donnees."
  type        = list(string)
  default     = ["10.20.2.0/24"]
}

variable "vm_size" {
  description = "Taille des machines virtuelles web."
  type        = string
  default     = "Standard_B2ts_v2"
}

variable "admin_username" {
  description = "Nom de l'utilisateur administrateur Linux."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Chemin local vers la cle publique SSH."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "allowed_ssh_cidr" {
  description = "Plage autorisee pour l'acces SSH, idealement l'adresse publique de l'administrateur en /32."
  type        = string
}

variable "mysql_admin_login" {
  description = "Identifiant administrateur de la base MySQL managee."
  type        = string
  default     = "novaadmin"
}

variable "mysql_admin_password" {
  description = "Mot de passe administrateur de la base MySQL managee. Ne doit jamais etre versionne."
  type        = string
  sensitive   = true
}

variable "mysql_sku_name" {
  description = "Gabarit du serveur MySQL Flexible."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "ops_email" {
  description = "Adresse de contact de l'equipe d'exploitation pour les alertes et le budget."
  type        = string
  default     = "equipe-ops@novaretail.example"
}

variable "monthly_budget_amount" {
  description = "Montant du budget mensuel du groupe de ressources, en euros."
  type        = number
  default     = 50
}
