# Partie 4. Administration, exploitation et automatisation

## Question 12. Inventaire d'exploitation

L'inventaire ci-dessous reprend les ressources réellement déployées dans le groupe `rg-novaretail-prod`, en région Sweden Central. Toutes les ressources portent les mêmes tags communs, à savoir application, environment, owner, cost_center, criticality, review_date et managed_by, ce qui facilite la lecture et le pilotage. La colonne du groupe de ressources est identique pour toutes les lignes, elle vaut `rg-novaretail-prod`.

| Nom | Type | Région | Rôle dans l'architecture |
|---|---|---|---|
| vnet-novaretail-prod | Virtual Network | Sweden Central | Réseau privé qui isole l'application et porte les subnets. |
| snet-web et snet-data | Subnets | Sweden Central | Séparent la couche web de la couche données. |
| nsg-novaretail-prod-web | Network Security Group | Sweden Central | Filtre les flux du subnet web et n'ouvre que les ports utiles. |
| nsg-novaretail-prod-data | Network Security Group | Sweden Central | Restreint l'accès à la base au seul subnet web. |
| vm-novaretail-prod-web-1 | Virtual Machine | Sweden Central | Première machine applicative qui sert l'application web. |
| vm-novaretail-prod-web-2 | Virtual Machine | Sweden Central | Seconde machine applicative qui assure la redondance. |
| nic-novaretail-prod-web-1 et 2 | Network Interfaces | Sweden Central | Connectent les machines au subnet web. |
| vm-novaretail-prod-web-1 et 2 OsDisk | Managed Disks | Sweden Central | Disques système des deux machines web. |
| pip-novaretail-prod-web-1 et 2 | Public IP Addresses | Sweden Central | Adresses publiques utilisées pour l'administration. |
| lb-novaretail-prod-web | Load Balancer | Sweden Central | Répartit le trafic entrant vers les deux machines web. |
| pip-novaretail-prod-lb | Public IP Address | Sweden Central | Adresse publique du point d'entrée web. |
| mysql-novaretail-prod | Azure Database for MySQL | Sweden Central | Base de données managée des commandes, non exposée. |
| novaretail.private.mysql... | Private DNS Zone | Global | Résolution privée du nom du serveur MySQL. |
| stnovaretail... | Storage Account | Sweden Central | Stockage privé des documents clients. |
| law-novaretail-prod | Log Analytics Workspace | Sweden Central | Espace de supervision des métriques et des journaux. |

L'inventaire complet au format texte est produit automatiquement par le script d'exploitation et conservé dans le dossier `exports`.

## Question 13. Tags et gouvernance

La stratégie de tags repose sur un ensemble de clés appliquées de façon uniforme à toutes les ressources par le code Terraform. Chaque clé répond à un besoin précis d'exploitation ou de pilotage des coûts.

| Tag | Exemple | Utilité |
|---|---|---|
| environment | prod | Distingue les environnements et permet de filtrer ou d'arrêter les ressources hors production. |
| application | novaretail | Relie chaque ressource à l'application concernée. |
| owner | equipe-cloud | Identifie l'équipe responsable et facilite l'escalade en cas d'incident. |
| cost_center | formation | Affecte les coûts à un budget pour le suivi FinOps. |
| criticality | medium | Aide à prioriser la surveillance et les actions de sécurité. |
| review_date | 2026-12-31 | Fixe une date de revue pour éviter que des ressources soient oubliées. |

Les tags sont essentiels pour l'administration et le FinOps. Du côté de l'administration, ils permettent de retrouver rapidement toutes les ressources d'une application ou d'un environnement, d'identifier le responsable d'une ressource et de cibler les actions de maintenance. Du côté du FinOps, ils permettent de ventiler les coûts par application, par environnement et par centre de coût, de poser des budgets précis et de repérer les ressources sans propriétaire qui risquent de générer des dépenses non maîtrisées. Comme les tags sont appliqués par Terraform, ils restent cohérents à chaque déploiement et ne dépendent pas d'une saisie manuelle.

## Question 14. Automatisation d'une tâche récurrente

Le script `scripts/inventaire_exploitation.sh` automatise un contrôle d'exploitation utile et a été exécuté réellement sur le groupe déployé.

L'objectif du script est de produire un inventaire des ressources d'un groupe donné, de vérifier que chaque ressource porte un tag obligatoire et d'afficher l'état des machines virtuelles. Cette tâche est utile au quotidien pour garder un inventaire à jour, contrôler la gouvernance des tags et vérifier rapidement la disponibilité des machines.

Les entrées attendues sont le nom du groupe de ressources, qui est obligatoire, et le nom du tag obligatoire à contrôler, qui est optionnel et vaut owner par défaut.

La sortie comprend un fichier CSV d'inventaire écrit dans le dossier `exports`, un résumé affiché à l'écran avec le nombre de ressources, la liste des ressources qui ne portent pas le tag obligatoire, et un tableau de l'état des machines virtuelles.

La logique principale s'appuie sur Azure CLI. Le script liste les ressources avec leur type, leur région et la valeur du tag contrôlé, puis il interroge séparément les ressources dont le tag est absent, et enfin il récupère l'état d'alimentation des machines virtuelles. Il commence par la directive de robustesse qui arrête l'exécution en cas d'erreur ou de variable non définie, il centralise ses paramètres dans des variables, et il n'effectue aucune modification.

Les limites du script sont les suivantes. Il lit l'état courant et ne corrige pas automatiquement les écarts, ce qui est volontaire pour éviter toute action non maîtrisée. Il dépend d'une session Azure CLI active et de droits de lecture sur le groupe. Il contrôle un seul tag obligatoire à la fois, même s'il pourrait être étendu pour vérifier une liste de tags.

Lors de l'exécution réelle, le script a inventorié dix huit ressources, a confirmé que toutes portaient le tag owner, et a montré les deux machines web en état d'exécution. La trace de cette exécution est conservée dans le dossier `screenshots`.
