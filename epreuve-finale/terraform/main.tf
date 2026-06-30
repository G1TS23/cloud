# Point d'entree du projet Terraform NovaRetail.
#
# Les ressources sont organisees par theme dans des fichiers dedies afin de
# rester lisibles : network.tf pour le reseau, security.tf pour les groupes de
# securite, compute.tf pour les machines, loadbalancer.tf pour le repartiteur de
# charge, storage.tf pour le stockage, database.tf pour la base managee,
# monitoring.tf pour la supervision et finops.tf pour le budget.
#
# Ce fichier porte le groupe de ressources qui contient l'ensemble.

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.prefix}"
  location = var.location
  tags     = local.common_tags
}
