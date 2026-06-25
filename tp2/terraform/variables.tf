variable "subscription_id" {
  description = "ID de la souscription Azure cible (compte de FORMATION). Sans valeur par defaut : il DOIT etre renseigne dans terraform.tfvars pour eviter tout deploiement accidentel sur un abonnement d'entreprise."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.subscription_id))
    error_message = "subscription_id doit etre un GUID Azure (36 caracteres). Recupere-le avec : az account show --query id -o tsv (apres avoir selectionne le bon compte)."
  }
}

variable "project" {
  description = "Nom court du projet"
  type        = string
  default     = "shopeasy"
}

variable "environment" {
  description = "Nom de l'environnement (dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Region Azure cible. swedencentral est retenue car la policy Azure for Students interdit francecentral."
  type        = string
  default     = "swedencentral"
}

variable "vm_size" {
  description = "Gabarit des VM web. Standard_B2ts_v2 est utilise car Standard_B1s est indisponible sur la souscription Students."
  type        = string
  default     = "Standard_B2ts_v2"
}

variable "admin_username" {
  description = "Utilisateur administrateur Linux"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Chemin local vers la cle publique SSH"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR autorise pour SSH (idealement l'IP publique de l'apprenant en /32)"
  type        = string
}

variable "vnet_address_space" {
  description = "Espace d'adressage du Virtual Network"
  type        = string
  default     = "10.20.0.0/16"
}

variable "web_subnet_prefix" {
  description = "Prefixe du subnet applicatif web"
  type        = string
  default     = "10.20.1.0/24"
}

variable "data_subnet_prefix" {
  description = "Prefixe du subnet prive de donnees (mise en autonomie - option A)"
  type        = string
  default     = "10.20.2.0/24"
}
