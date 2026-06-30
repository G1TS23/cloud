# Infrastructure Terraform — NovaRetail

Code Infrastructure as Code (IaC) déployant l'architecture cible de migration de l'application NovaRetail vers Azure.

## Prérequis

- [Terraform](https://www.terraform.io/) >= 1.5
- [Azure CLI](https://learn.microsoft.com/cli/azure/) connecté (`az login`)
- Une souscription Azure active (testé sur **Azure for Students**, région `swedencentral`)

Vérifier le compte actif avant tout déploiement :

```bash
../scripts/azure-account.sh
```

## Structure du projet

| Fichier | Rôle |
|---|---|
| `main.tf` | Déclaration de toutes les ressources Azure (réseau, VM, LB, stockage, supervision, base managée) et du provider. |
| `variables.tf` | Définition des variables d'entrée (nom de projet, région, environnement, préfixe, adressage, taille des VM, tags...). |
| `outputs.tf` | Valeurs exposées après déploiement (RG, IP publique, nom du Storage Account, URL de l'app...). |
| `terraform.tfvars` | Valeurs concrètes des variables pour ce déploiement (aucun secret). |
| `.gitignore` | Empêche le versionnement du state, des secrets et des clés. |
| `README.md` | Ce fichier — mode d'emploi du projet. |

## Ressources déployées

- **Resource Group** `rg-novaretail-prod`
- **Virtual Network** `10.10.0.0/16` + **2 subnets** (`snet-web`, `snet-data`)
- **2 Network Security Groups** (`nsg-web` : HTTP/HTTPS + SSH restreint ; `nsg-data` : MySQL depuis le web uniquement)
- **2 VM Linux Ubuntu** (`Standard_B1s`) avec Apache installé via cloud-init
- **Load Balancer standard** public (haute disponibilité + SNAT sortant)
- **Storage Account** privé (versioning + soft delete 7 j)
- **Log Analytics Workspace** (supervision)
- **Azure Database for MySQL Flexible Server** (optionnel, `deploy_mysql`)

## Utilisation

```bash
# 1. Initialiser (téléchargement des providers)
terraform init

# 2. Visualiser le plan d'exécution
terraform plan

# 3. Appliquer (création réelle des ressources)
terraform apply

# 4. Récupérer les sorties (ex. URL de l'application)
terraform output web_application_url

# 5. Récupérer la clé SSH privée si besoin
terraform output -raw ssh_private_key > novaretail_id_rsa
chmod 600 novaretail_id_rsa

# 6. Détruire l'infrastructure (après remise, pour économiser le crédit)
terraform destroy
```

## Sécurité

- **Aucun mot de passe en dur** : la clé SSH des VM et le mot de passe MySQL sont générés par Terraform (`tls`, `random`) et exposés uniquement en sortie sensible.
- **Storage privé** : `public_network_access_enabled = false`, accès public aux blobs désactivé.
- **SSH restreint** : la règle NSG n'ouvre jamais le port 22 depuis `0.0.0.0/0` (variable `admin_source_address`).
- **State** : pour la production, activer le backend distant `azurerm` (bloc commenté dans `main.tf`).

## Optimisation des coûts (FinOps)

- VM en `Standard_B1s` (burstable, faible coût).
- `deploy_mysql = false` permet un déploiement plus rapide et moins coûteux pour les tests.
- **Penser à `terraform destroy`** après validation pour ne pas consommer de crédit inutilement.
