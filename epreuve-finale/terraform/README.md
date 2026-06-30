# Projet Terraform NovaRetail

Ce projet décrit et déploie l'infrastructure cible de NovaRetail sur Microsoft Azure. Il crée un groupe de ressources, un réseau virtuel segmenté, des groupes de sécurité réseau, deux machines web derrière un répartiteur de charge, une base de données MySQL managée, un compte de stockage et un espace de supervision.

## Rôle de chaque fichier

| Fichier | Rôle |
|---|---|
| `versions.tf` | Déclare la version de Terraform et les fournisseurs azurerm et random. |
| `providers.tf` | Configure le fournisseur Azure et épingle l'abonnement de formation. |
| `variables.tf` | Déclare les paramètres d'entrée comme le projet, la région, l'adressage et la taille des machines. |
| `locals.tf` | Calcule le préfixe de nommage et les tags communs appliqués à toutes les ressources. |
| `network.tf` | Crée le groupe de ressources, le réseau virtuel et les deux subnets. |
| `security.tf` | Crée les groupes de sécurité réseau, leurs règles et leurs associations aux subnets. |
| `compute.tf` | Crée les adresses publiques, les interfaces réseau et les deux machines web avec leur configuration cloud-init. |
| `loadbalancer.tf` | Crée le répartiteur de charge, le pool de backend, la sonde de santé et la règle de répartition. |
| `storage.tf` | Crée le compte de stockage privé et un conteneur pour les documents. |
| `database.tf` | Crée la zone DNS privée, le lien réseau, le serveur MySQL managé et la base applicative. |
| `monitoring.tf` | Crée l'espace de travail Log Analytics pour la supervision. |
| `outputs.tf` | Expose les informations utiles après le déploiement. |
| `templates/cloud-init.yml` | Installe Apache et PHP au premier démarrage des machines web. |
| `terraform.tfvars.example` | Exemple de valeurs à recopier dans terraform.tfvars sans secret versionné. |

## Variables principales

Les variables permettent d'adapter le projet sans modifier le code. Elles couvrent le nom du projet, la région Azure, l'environnement, le préfixe de nommage, la plage d'adressage du réseau et la taille des machines. Le mot de passe de la base est une variable sensible qui ne doit jamais être versionnée.

## Outputs

Le projet expose au moins trois sorties utiles, à savoir le nom du groupe de ressources, l'adresse publique du point d'entrée web sur le répartiteur de charge et le nom du compte de stockage. Il expose également les adresses des machines web et le nom de domaine privé du serveur MySQL.

## Utilisation

1. Copier le fichier `terraform.tfvars.example` en `terraform.tfvars` et renseigner l'adresse SSH autorisée ainsi que le mot de passe de la base.
2. Vérifier que la session Azure CLI pointe sur l'abonnement de formation.
3. Lancer la séquence Terraform.

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
```

À la fin de la séance, l'environnement doit être supprimé pour éviter les coûts résiduels.

```bash
terraform destroy
```

## Contraintes

La région retenue est Sweden Central et la taille des machines est Standard_B2ts_v2, en raison des limites de l'abonnement de formation. La base MySQL utilise un gabarit Burstable. Le state Terraform reste local dans ce cadre, mais une évolution recommandée consiste à le stocker dans un backend distant protégé.
