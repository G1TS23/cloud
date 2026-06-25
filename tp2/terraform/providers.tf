provider "azurerm" {
  features {}

  # Epingle explicitement la souscription cible : Terraform agit sur CET abonnement,
  # independamment du compte par defaut de `az` (garde-fou anti-deploiement sur le mauvais compte).
  subscription_id = var.subscription_id
}
