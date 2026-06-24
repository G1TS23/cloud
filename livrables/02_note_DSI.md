# Note de recommandations DSI — Migration de ShopEasy vers Microsoft Azure

**Destinataire :** Direction des Systèmes d'Information
**Auteur :** Architecte cloud junior
**Objet :** Proposition d'architecture cible Azure pour l'application de gestion de commandes ShopEasy

---

## 1. Contexte

ShopEasy exploite une application interne de gestion de commandes (clients, commandes, factures, documents justificatifs), utilisée par les équipes commerciales, le service client et la logistique. Elle repose aujourd'hui sur **un unique serveur physique** hébergeant à la fois le serveur web, l'application, la base MySQL et les documents.

Cette situation présente des limites majeures : **point de défaillance unique**, sauvegardes manuelles et irrégulières, **absence de supervision**, **compte administrateur partagé** et aucune séparation des couches. Tout incident matériel entraîne un arrêt complet de l'activité et un risque de perte de données.

## 2. Architecture Azure proposée

Une architecture segmentée et redondée dans la région **France Central**, regroupée dans un Resource Group dédié (`rg-shopeasy-dev`) :

- **Réseau** : un Virtual Network (`10.10.0.0/16`) découpé en subnets *web*, *data* et *admin*.
- **Couche web** : deux machines virtuelles Linux (Nginx) derrière un **Azure Load Balancer**.
- **Base de données** : **Azure SQL Database** (managée), non exposée sur Internet.
- **Stockage** : **Storage Account** privé (Blob) pour les documents clients.
- **Sécurité réseau** : **Network Security Groups** restrictifs par subnet.
- **Identités** : **Microsoft Entra ID + RBAC**, comptes nominatifs.
- **Supervision** : **Azure Monitor** (métriques, logs, alertes).

*(Schéma d'architecture détaillé joint en annexe.)*

## 3. Services retenus et leur rôle

| Service | Rôle | Modèle |
|---|---|---|
| Virtual Network + subnets | Isolation et segmentation réseau | IaaS |
| Network Security Groups | Filtrage des flux | IaaS |
| Virtual Machines (×2) | Hébergement applicatif | IaaS |
| Load Balancer | Répartition de charge, résilience web | IaaS |
| Azure SQL Database | Base relationnelle managée | PaaS |
| Storage Account (Blob) | Stockage documentaire durable | PaaS |
| Entra ID + RBAC | Gestion des identités et droits | Gouvernance |
| Azure Monitor | Supervision et alerting | PaaS/Gouvernance |
| Cost Management | Suivi et optimisation des coûts | Gouvernance |

## 4. Gains attendus

- **Disponibilité** : suppression du SPOF web (2 VM + load balancer), base et stockage managés et durables.
- **Sécurité** : segmentation réseau, filtrage NSG, comptes nominatifs, traçabilité, chiffrement au repos.
- **Exploitation** : supervision centralisée, alerting, sauvegardes automatiques de la base.
- **Coûts** : visibilité via tags et Cost Management, leviers d'optimisation (auto-shutdown, serverless).
- **Évolutivité** : socle prêt pour l'automatisation (IaC) et l'ajout de zones de disponibilité.

## 5. Risques résiduels

L'architecture proposée reste volontairement simplifiée (cadre pédagogique). Subsistent :
- déploiement **mono-zone** (vulnérable à une panne de datacenter) ;
- SSH et IP publiques encore présents sur les VM ;
- HTTPS/WAF non encore en place ;
- base et stockage accessibles par règles réseau plutôt que par Private Endpoint.

## 6. Estimation budgétaire

Estimation indicative : **~45 à 65 €/mois** pour l'environnement de test (2 VM B1s, disques, Load Balancer, Storage, SQL serverless, monitoring). À affiner via Azure Pricing Calculator selon le volume réel.

## 7. Actions prioritaires

**Court terme**
1. Déployer le socle (RG, VNet, NSG, 2 VM, LB).
2. Migrer la base vers Azure SQL et les documents vers le Storage Account.
3. Mettre en place comptes nominatifs + MFA + RBAC ; fermer SSH public.
4. Activer supervision et alertes.

**Moyen terme**
5. HTTPS + Application Gateway/WAF, Azure Bastion, Private Endpoints.
6. Déploiement multi-zone, sauvegardes testées, plan de reprise.
7. **Infrastructure as Code** (Terraform/Bicep) + pipeline CI/CD.

## 8. Limites de la proposition

Il s'agit d'une **première itération** destinée à valider l'approche et à former l'équipe. Elle ne couvre pas encore la résilience multi-région, la conformité réglementaire complète, ni l'automatisation du déploiement. Ces aspects relèvent d'un projet de production ultérieur, à dimensionner selon la criticité réelle de l'application.
