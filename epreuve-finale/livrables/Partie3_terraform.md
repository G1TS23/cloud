# Partie 3. Déploiement et Infrastructure as Code

Le code complet se trouve dans le dossier `terraform`. Il décrit l'architecture cible de la partie 1 et il a été déployé réellement sur l'abonnement de formation.

## Question 8. Organisation du projet Terraform

Le projet est découpé en fichiers thématiques plutôt qu'en un seul fichier, afin qu'une personne qui ne l'a pas écrit puisse le comprendre rapidement. Le rôle de chaque fichier est le suivant.

| Fichier | Rôle |
|---|---|
| `versions.tf` | Déclare la version minimale de Terraform et les fournisseurs azurerm et random. |
| `providers.tf` | Configure le fournisseur Azure et épingle l'abonnement de formation pour éviter tout déploiement sur un autre compte. |
| `variables.tf` | Déclare les paramètres d'entrée du projet. |
| `locals.tf` | Calcule le préfixe de nommage et les tags communs appliqués à toutes les ressources. |
| `network.tf` | Crée le groupe de ressources, le réseau virtuel et les deux subnets. |
| `security.tf` | Crée les deux groupes de sécurité réseau, leurs règles et leurs associations. |
| `compute.tf` | Crée les adresses publiques, les interfaces réseau et les deux machines web. |
| `loadbalancer.tf` | Crée le répartiteur de charge, le pool de backend, la sonde de santé et la règle de répartition. |
| `storage.tf` | Crée le compte de stockage privé et son conteneur. |
| `database.tf` | Crée la zone DNS privée, le lien réseau, le serveur MySQL managé et la base applicative. |
| `monitoring.tf` | Crée l'espace de travail Log Analytics. |
| `outputs.tf` | Expose les informations utiles après le déploiement. |
| `templates/cloud-init.yml` | Installe Apache et PHP au premier démarrage des machines. |
| `terraform.tfvars.example` | Donne un exemple de valeurs à recopier sans secret versionné. |
| `README.md` | Explique le rôle des fichiers et la procédure d'utilisation. |

Le sujet demande au minimum les fichiers `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars` et un `README.md`. Le rôle attendu d'un fichier `main.tf` est ici réparti dans les fichiers thématiques `network.tf`, `security.tf`, `compute.tf`, `loadbalancer.tf`, `storage.tf`, `database.tf` et `monitoring.tf`, ce qui améliore la lisibilité sans changer le résultat.

## Question 9. Ressources créées

Le projet crée l'ensemble des ressources attendues, à savoir un Resource Group, un réseau virtuel, deux subnets, deux groupes de sécurité réseau avec des règles HTTP, HTTPS et SSH maîtrisées, deux machines virtuelles Linux configurées par cloud-init, un répartiteur de charge avec sonde et règle, un compte de stockage privé, une base de données MySQL managée et un espace de travail Log Analytics pour la supervision.

Les règles de filtrage suivent le principe du moindre accès. Le groupe de sécurité du subnet web autorise les ports 80 et 443 depuis Internet et le port 22 uniquement depuis l'adresse de l'administrateur. Le groupe de sécurité du subnet de données autorise le port 3306 uniquement depuis la plage du subnet web, ce qui empêche toute exposition directe de la base sur Internet.

## Question 10. Variables et outputs

Le code utilise des variables pour tous les éléments demandés, ce qui le rend réutilisable sur plusieurs environnements sans modification. Les variables couvrent le nom du projet, la région Azure, l'environnement, le préfixe de nommage calculé à partir du projet et de l'environnement, la plage d'adressage du réseau virtuel et la taille des machines. Le mot de passe de la base est déclaré comme variable sensible afin qu'il n'apparaisse pas en clair dans les sorties.

Le projet expose cinq outputs. Les trois principaux sont le nom du groupe de ressources, l'adresse publique du point d'entrée web sur le répartiteur de charge et le nom du compte de stockage. Les deux autres exposent les adresses des machines web et le nom de domaine privé du serveur MySQL, ce qui facilite l'administration et la connexion applicative.

## Question 11. Validation du déploiement

Le déploiement a été réalisé réellement avec la séquence Terraform habituelle, à savoir l'initialisation, le formatage, la validation, la prévisualisation par un plan, puis l'application. Les preuves de validation sont rassemblées dans le dossier `screenshots` et comprennent le groupe de ressources, le réseau virtuel et ses subnets, les groupes de sécurité réseau, les machines web, le point d'entrée HTTP et un extrait lisible du résultat du déploiement.

L'application a réussi avec la mention finale indiquant vingt neuf ressources ajoutées, sans modification ni suppression. Les serveurs web répondent à travers le répartiteur de charge, et chaque machine renvoie sa propre page, ce qui confirme la répartition de charge. Les valeurs réelles produites par le déploiement sont les suivantes.

| Sortie | Valeur réelle |
|---|---|
| Groupe de ressources | rg-novaretail-prod |
| Adresse publique du point d'entrée web | 20.91.214.201 |
| Adresses des machines web | 4.223.75.235 et 20.240.138.86 |
| Compte de stockage | stnovaretailp2fxae |
| Serveur MySQL managé | mysql-novaretail-prod-p2fxae.mysql.database.azure.com |

Le test du point d'entrée renvoie la page de la première machine, et le test direct de chaque machine renvoie sa page propre, ce qui valide à la fois la couche web et la répartition. L'inventaire des ressources confirme la présence du groupe de ressources, du réseau virtuel et de ses deux subnets, des deux groupes de sécurité réseau, des deux machines avec leurs interfaces et adresses, du répartiteur de charge, du compte de stockage, de la base MySQL managée avec sa zone DNS privée, et de l'espace de travail Log Analytics. Les extraits du résultat de déploiement et de l'inventaire sont fournis dans le dossier `screenshots`.
