# Partie 1. Analyse de l'existant et architecture cible

## Question 1. Analyse de l'existant

L'application de gestion de commandes de NovaRetail repose aujourd'hui sur un serveur Linux unique qui héberge en même temps le serveur web Apache et PHP, la base de données MySQL et les fichiers clients. Les sauvegardes sont manuelles et hebdomadaires, aucune supervision n'est en place, et un compte administrateur est partagé entre plusieurs personnes. Cette concentration crée des risques dans chaque grand domaine d'exploitation.

| Domaine | Risque identifié | Impact possible sur le SI |
|---|---|---|
| Disponibilité | Le serveur est unique et sans redondance, ce qui constitue un point de défaillance unique. | La moindre panne matérielle ou logicielle interrompt totalement la prise de commandes et l'activité commerciale. |
| Sécurité | Le compte administrateur est partagé et les couches ne sont pas cloisonnées, tandis que la base et les fichiers sont exposés sur la même machine. | La traçabilité des actions disparaît, une seule compromission donne un accès complet, et les données clients peuvent fuir. |
| Performance | Le web, la base MySQL et le stockage partagent les mêmes ressources sur une seule machine. | Les montées en charge provoquent de la contention et des lenteurs, sans possibilité d'absorber un pic de commandes. |
| Exploitation | Aucun tableau de bord ni aucune alerte ne permet de suivre l'état du système. | Les incidents sont détectés tardivement, souvent par les utilisateurs, et le diagnostic est long. |
| Coûts | Aucune estimation des coûts d'exploitation n'existe et le dimensionnement reste figé. | Les dépenses ne sont ni mesurées ni optimisées, et tout surdimensionnement passe inaperçu. |
| Sauvegarde | La sauvegarde est manuelle, hebdomadaire et conservée sur le même périmètre que la production. | La perte de données peut atteindre une semaine entière, sans garantie de restauration ni test de reprise. |

Les besoins techniques prioritaires qui découlent de cette analyse sont la haute disponibilité de la couche web, l'externalisation de la base et des fichiers vers des services dédiés, la segmentation et le filtrage du réseau, la mise en place d'une supervision avec des alertes, l'usage de comptes nominatifs avec des droits limités, et une sauvegarde automatisée et testée.

## Question 2. Choix des services Azure

Le tableau associe chaque besoin de NovaRetail à un service Azure, en justifiant le choix selon les critères de coût, de sécurité, de disponibilité et d'exploitabilité.

| Besoin | Service Azure proposé | Justification |
|---|---|---|
| Hébergement applicatif | Azure Virtual Machines, deux machines Linux placées derrière un répartiteur de charge | Cette approche en infrastructure as a service permet une migration proche de l'existant Apache et PHP, tout en supprimant le point de défaillance unique grâce à la redondance des instances. |
| Réseau isolé | Azure Virtual Network avec des subnets séparés | Le réseau virtuel isole logiquement l'application et permet de séparer la couche web de la couche données afin de limiter les déplacements latéraux en cas d'incident. |
| Filtrage réseau | Network Security Groups appliqués aux subnets | Les groupes de sécurité réseau restreignent les flux aux seuls ports nécessaires et limitent l'exposition de chaque couche. |
| Stockage de documents | Azure Storage Account avec des conteneurs Blob privés | Le stockage objet externalise les fichiers clients hors des machines, assure leur durabilité par réplication et autorise le versioning et les politiques de cycle de vie. |
| Base de données managée | Azure Database for MySQL Flexible Server | Le choix d'un service managé plutôt qu'une base installée sur machine virtuelle délègue à Azure les sauvegardes automatiques, les correctifs, la supervision et les options de haute disponibilité, ce qui réduit la charge d'exploitation et le risque humain. Le choix du moteur MySQL plutôt qu'Azure SQL conserve la compatibilité avec la base MySQL déjà utilisée par NovaRetail, ce qui évite une migration de moteur et une réécriture applicative. |
| Supervision | Azure Monitor relié à un Log Analytics Workspace | La supervision centralise les métriques et les journaux, permet d'analyser la performance et de déclencher des alertes actionnables. |
| Gestion des coûts | Microsoft Cost Management avec des budgets et des alertes | Cet outil rend les dépenses visibles, les rattache à des tags et prévient en cas de dépassement budgétaire. |
| Gestion des droits | Microsoft Entra ID associé au contrôle d'accès basé sur les rôles | Les comptes deviennent nominatifs et chaque personne ne reçoit que les droits strictement nécessaires, selon le principe du moindre privilège. |
| Journalisation et audit | Journal d'activité et paramètres de diagnostic exportés vers Log Analytics | La traçabilité des opérations de gestion est conservée et interrogeable, ce qui permet de répondre aux questions d'audit. |

Chaque service se classe dans une catégorie de responsabilité. Les machines virtuelles, le réseau virtuel et les groupes de sécurité réseau relèvent de l'infrastructure as a service, où l'équipe garde la responsabilité du système et de l'application. La base MySQL managée, le compte de stockage et la supervision relèvent de la plateforme as a service, où Azure prend en charge une partie de l'exploitation. La gestion des identités et le suivi des coûts relèvent de la gouvernance, qui encadre les droits et les dépenses de façon transverse.

## Question 3. Architecture cible

L'architecture cible regroupe toutes les ressources dans un même Resource Group nommé `rg-novaretail-prod`, déployé dans la région Sweden Central. Un Virtual Network nommé `vnet-novaretail-prod` couvre la plage 10.20.0.0/16 et se découpe en deux subnets. Le subnet web `snet-web` en 10.20.1.0/24 accueille les deux machines applicatives, et le subnet données `snet-data` en 10.20.2.0/24 accueille les services de données et les connexions privées.

La couche web comprend deux machines virtuelles Linux nommées `vm-web-01` et `vm-web-02`, de taille Standard_B2ts_v2, qui exécutent Apache et PHP. Ces machines sont placées derrière un répartiteur de charge Azure Load Balancer qui répartit le trafic et s'appuie sur une sonde de santé. Le groupe de sécurité réseau `nsg-web` autorise les ports 80 et 443 depuis Internet et le port 22 uniquement depuis l'adresse de l'administrateur. Le groupe de sécurité réseau `nsg-data` autorise le port 3306 uniquement depuis le subnet web et refuse tout accès depuis Internet.

La base de données est un service Azure Database for MySQL Flexible Server, rattaché au subnet données et non exposé publiquement. Les fichiers clients sont déplacés vers un Storage Account privé avec versioning. Azure Monitor et un Log Analytics Workspace collectent les métriques et les journaux de l'ensemble des ressources. Microsoft Entra ID et le contrôle d'accès basé sur les rôles encadrent l'administration, et des tags cohérents sont appliqués pour la gouvernance et le suivi des coûts.

Les flux principaux sont les suivants. Le trafic des utilisateurs arrive depuis Internet vers le répartiteur de charge, qui le distribue vers les deux machines web sur le port 80 ou 443. Les machines web accèdent à la base MySQL sur le port 3306 depuis le subnet web uniquement. Les machines web accèdent au Storage Account en HTTPS pour lire et écrire les documents. L'administration passe par le port 22 restreint à l'adresse de l'administrateur, avec Azure Bastion comme évolution recommandée. Toutes les ressources envoient leurs métriques et leurs journaux vers le Log Analytics Workspace.

Le schéma correspondant est fourni dans le dossier `schema`, au format draw.io modifiable et au format image exporté.

### Justification courte des principaux choix

La redondance de la couche web derrière un répartiteur de charge répond au besoin de disponibilité en supprimant le point de défaillance unique. Le choix d'une base managée plutôt qu'une base installée sur machine virtuelle décharge l'équipe des sauvegardes et des correctifs, ce qui réduit le risque d'exploitation. L'externalisation des fichiers vers un stockage objet privé améliore la durabilité et la confidentialité des données clients. La segmentation du réseau en deux subnets associés à des groupes de sécurité restreints applique une défense en profondeur. La supervision et la gouvernance des identités complètent l'ensemble pour rendre l'environnement exploitable et auditable.

Pour une cible de production plus exigeante, une Application Gateway avec un pare-feu applicatif web pourrait remplacer le simple répartiteur de charge, et un Private Endpoint pourrait isoler complètement la base et le stockage du réseau public.
