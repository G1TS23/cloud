# Partie 2. Diagnostic d'une architecture défectueuse

Cette partie audite l'architecture proposée par un prestataire externe pour NovaRetail avant toute mise en production. L'objectif est de repérer les anomalies, de prioriser les risques et de proposer des corrections réalistes.

## Question 4. Identification des anomalies

Le tableau ci-dessous relève quatorze anomalies, chacune rattachée à un domaine et associée à son risque principal.

| No | Anomalie identifiée | Domaine | Risque principal |
|---|---|---|---|
| 1 | Le port MySQL 3306 est accessible depuis Internet. | Sécurité | La base de données clients est exposée à des accès non autorisés, des injections et des exfiltrations. |
| 2 | Le port SSH est ouvert depuis 0.0.0.0/0. | Sécurité | Les machines subissent des attaques par force brute et peuvent être compromises. |
| 3 | Les mots de passe administrateurs sont stockés dans un fichier terraform.tfvars versionné dans Git. | Sécurité et IaC | Les identifiants fuient dès que le dépôt est partagé ou cloné. |
| 4 | Le state Terraform est local sur le poste d'un administrateur. | IaC | Le state peut être perdu, il n'offre aucun verrouillage et il peut contenir des données sensibles. |
| 5 | Le Storage Account autorise l'accès public aux blobs. | Sécurité | Les documents clients deviennent accessibles publiquement sur Internet. |
| 6 | Le versioning et la suppression réversible ne sont pas activés sur le Storage Account. | Exploitation | Une suppression ou un écrasement de fichier est irréversible. |
| 7 | Aucune sauvegarde n'est configurée. | Disponibilité | Une panne ou une erreur entraîne une perte définitive de données sans reprise possible. |
| 8 | Les deux machines web ne sont pas placées derrière un répartiteur de charge. | Disponibilité | La panne d'une machine interrompt le service et la charge n'est pas répartie. |
| 9 | La base MySQL est installée sur une machine dans le même subnet que les serveurs web. | Sécurité et disponibilité | L'absence de cloisonnement facilite les déplacements latéraux et la base partage les ressources du web. |
| 10 | Le réseau se limite à un seul Virtual Network 10.0.0.0/24 avec un seul subnet. | Réseau et sécurité | L'absence de segmentation empêche tout filtrage par couche et augmente la surface d'exposition. |
| 11 | Un seul Resource Group contient les ressources de développement et de production. | Gouvernance | Une manipulation sur le développement peut affecter la production. |
| 12 | Aucune séparation claire n'existe entre l'environnement de test et l'environnement de production. | Gouvernance | Un changement de test peut impacter directement la production. |
| 13 | Plusieurs utilisateurs humains disposent du rôle Owner sur la souscription. | Sécurité et gouvernance | Les droits sont excessifs et un seul compte compromis donne le contrôle total. |
| 14 | Aucun Log Analytics Workspace, aucune alerte, aucune stratégie de tags et aucun budget ne sont en place. | Exploitation et FinOps | Les incidents ne sont pas détectés et les coûts ne sont ni attribuables ni maîtrisés. |

## Question 5. Priorisation des risques

Parmi les anomalies relevées, les cinq risques les plus critiques sont les suivants.

| Risque critique | Niveau | Justification | Correction prioritaire |
|---|---|---|---|
| Base MySQL exposée sur Internet par le port 3306 | Critique | La base contient les données clients et commandes, son exposition directe est la porte d'entrée la plus dangereuse. | Fermer tout accès depuis Internet, placer la base dans un subnet privé ou un service managé non exposé, et n'autoriser que le subnet web. |
| Accès SSH ouvert depuis 0.0.0.0/0 | Critique | Un port d'administration ouvert au monde entier est en permanence attaqué et permet une prise de contrôle des machines. | Restreindre l'accès à l'adresse de l'administrateur, puis évoluer vers Azure Bastion. |
| Secrets versionnés dans Git | Critique | Un mot de passe administrateur présent dans le dépôt est une fuite d'identifiants difficile à rattraper. | Retirer le secret du dépôt, l'ajouter au fichier d'exclusion, le stocker dans Azure Key Vault et procéder à une rotation. |
| Accès public au Storage Account | Élevé | Les documents clients sont des données sensibles qui ne doivent jamais être publiques. | Désactiver l'accès public aux blobs, rendre les conteneurs privés et activer la suppression réversible. |
| Rôle Owner attribué à plusieurs personnes | Élevé | Des droits trop larges augmentent la surface d'attaque et le risque d'erreur ou d'abus. | Appliquer le principe du moindre privilège, réserver le rôle Owner et utiliser des rôles plus restreints. |

## Question 6. Proposition d'architecture corrigée

L'architecture corrigée correspond à l'architecture cible décrite dans la partie 1 et réellement déployée dans la partie 3. Le schéma se trouve dans le dossier `schema`. Les corrections apportées répondent point par point aux anomalies relevées.

La séparation des environnements est assurée en isolant le développement et la production dans des groupes de ressources distincts, et en paramétrant le code Terraform par une variable d'environnement, ce qui permet de déployer chaque environnement à partir du même code sans les mélanger. La segmentation du réseau remplace le subnet unique par un Virtual Network plus large découpé en un subnet web et un subnet de données. Le filtrage réseau est confié à des groupes de sécurité qui n'ouvrent que les ports utiles, à savoir les ports 80 et 443 depuis Internet et le port 22 depuis la seule adresse de l'administrateur.

Les expositions inutiles à Internet sont supprimées. La base n'est plus accessible que depuis le subnet web sur le port 3306, et l'évolution recommandée consiste à retirer les adresses publiques des machines au profit d'un accès privé. La base MySQL installée sur une machine est remplacée par le service managé Azure Database for MySQL, ce qui apporte les sauvegardes automatiques et les correctifs. Les secrets sont gérés de façon sécurisée, hors du dépôt, avec un stockage dans Azure Key Vault comme cible. Le state Terraform est externalisé dans un backend distant protégé, sur un compte de stockage dédié avec verrouillage et contrôle d'accès.

La supervision, les alertes, les sauvegardes et les tags sont mis en place avec un espace Log Analytics, des alertes de processeur et de disponibilité, les sauvegardes automatiques de la base managée et une stratégie de tags appliquée par le code. La maîtrise des coûts est assurée par un budget mensuel et des notifications de dépassement.

## Question 7. Plan de vérification

Le plan de vérification ci-dessous permet de confirmer que les corrections sont bien appliquées, avec au moins un contrôle par domaine.

La vérification réseau consiste à lister les règles des groupes de sécurité et à confirmer que le port 3306 n'est ouvert que depuis le subnet web et que le port 22 est restreint à l'adresse de l'administrateur. Un test complémentaire vérifie qu'une tentative de connexion à la base depuis Internet échoue.

La vérification de sécurité et de RBAC consiste à lister les attributions de rôles sur la souscription et à confirmer qu'un seul compte dispose du rôle Owner. Elle inclut un contrôle qui s'assure qu'aucun secret n'est présent dans le dépôt Git.

La vérification Terraform consiste à exécuter un plan qui ne doit annoncer aucune dérive, et à confirmer que le state est stocké dans un backend distant et que le fichier de variables sensibles est exclu du dépôt.

La vérification du monitoring consiste à confirmer la présence de l'espace Log Analytics et des règles d'alerte, et à vérifier que les alertes sont actives et reliées à un groupe d'action.

La vérification FinOps consiste à confirmer la présence du budget et de ses seuils, et à exécuter le script d'inventaire pour s'assurer que toutes les ressources portent les tags obligatoires.
