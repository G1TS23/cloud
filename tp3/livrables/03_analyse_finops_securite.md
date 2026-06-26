# TP3 — Analyse FinOps et sécurité d'exploitation (ateliers 11 et corrigé sécurité)

> Périmètre : `rg-shopeasy-dev` (souscription *Azure for Students*, `swedencentral`).
> Deux VM `Standard_B2ts_v2`, un Load Balancer, un compte de stockage, deux NSG.

## 1. Analyse FinOps (atelier 11)

### Ressources génératrices de coût

Dans cet environnement de développement, le **compute** domine la facture : les deux VM `Standard_B2ts_v2` tournent 24h/24 alors que l'usage réel est ponctuel. Viennent ensuite les **disques OS managés** (facturés même VM désallouée), les **IP publiques Standard** (facturées à l'heure), puis le **stockage** (faible volume ici).

### Tableau des actions FinOps

| Action | Effet attendu | Risque ou limite | Décision pour ShopEasy dev |
|---|---|---|---|
| Désallouer les VM hors usage | Réduit le coût compute (le plus gros poste) | Indisponibilité pendant l'arrêt | **Retenue** — arrêt nocturne et week-end via `vm-power.sh deallocate` |
| Réduire la taille des VM | Réduit le coût mensuel | Performance plus faible | Possible — `B2ts_v2` est déjà petit ; à réévaluer si CPU < 5 % en continu |
| Supprimer les disques inutilisés | Réduit le stockage facturé | Risque de perte de données | À faire après `terraform destroy` (pas de disque orphelin actuellement) |
| Standardiser les tags | Meilleure ventilation des coûts | Discipline d'équipe nécessaire | **Retenue** — compléter le tag `Application` sur les 12 ressources restantes |
| Définir un budget | Alerte en cas de dérive | Ne bloque pas la dépense | **Retenue** — budget mensuel + alerte à 80 % |

### Stratégie d'arrêt/démarrage des VM de développement

Les VM `dev` n'ont pas besoin d'être disponibles la nuit ni le week-end. La stratégie retenue : **désallocation automatique** en dehors des heures ouvrées (par exemple 20h–8h et le week-end), via le script [`vm-power.sh`](../scripts/vm-power.sh) déclenché par un cron / une Azure Automation runbook. Sur une base 24/7 ramenée à ~50 h/semaine d'allocation, l'économie compute approche **60–70 %**. Le démarrage matinal peut être planifié ou laissé à la demande (`vm-power.sh start`).

### Politique de tags FinOps

Tags obligatoires sur **toute** ressource : `Application` (ventilation par produit), `Environment` (cible des actions d'arrêt), `Owner` (responsable), `CostCenter` (refacturation), `ManagedBy` (IaC vs manuel). Un contrôle automatisé (le compteur « ressources sans tag `Application` » d'`inventory.sh`) signale les manquements ; en production, une **Azure Policy** en mode `deny` ou `append` imposerait les tags à la création.

### Seuil d'alerte budgétaire

Pour un environnement de formation, un **budget mensuel de l'ordre de 30 € à 50 €** avec une **alerte à 80 %** (et une seconde à 100 %) est pertinent : assez bas pour réagir avant l'épuisement du crédit *Azure for Students*, assez haut pour ne pas alerter sur le bruit quotidien. Le budget se définit dans Cost Management (`az consumption budget create`).

### Trois recommandations FinOps pour la DSI

1. **Automatiser la désallocation nocturne** des environnements non-prod : c'est le levier d'économie le plus rapide et le plus sûr (réversible).
2. **Imposer les tags via Azure Policy** : sans tags fiables, l'analyse de coût par application est impossible et la refacturation interne échoue.
3. **Mettre en place un budget avec alertes** par environnement, couplé à une revue mensuelle des ressources orphelines (disques, IP publiques non attachées).

---

## 2. Analyse sécurité d'exploitation (corrigé sécurité)

### Risques identifiés et mesures correctives

| Risque | Constat sur l'environnement | Mesure corrective | Statut |
|---|---|---|---|
| SSH exposé à Internet | NSG `Allow-SSH-Admin` limité à l'IP de l'administrateur (`/32`), pas `0.0.0.0/0` | Maintenir la restriction ; en prod, passer par Azure Bastion | Conforme |
| Stockage public | `allowBlobPublicAccess` était à `True` (défaut Terraform) | Désactivé en TP3 (`--allow-blob-public-access false`) + conteneur privé | Corrigé |
| Accès stockage par clés | Risque de fuite de clés de compte | Auth Entra ID (`--auth-mode login`) + rôle RBAC `Storage Blob Data Contributor` | Conforme |
| Absence de supervision | Aucune alerte au départ | Alerte CPU créée (atelier 8) | Corrigé |
| Actions destructives non tracées | Scripts d'arrêt potentiellement dangereux | `vm-power.sh` : confirmation, anti-prod, journalisation | Conforme |
| Tags d'ownership manquants | 12 ressources sans `Application` | Normalisation des tags en cours (atelier 3) | Partiel |

### Contrôle des NSG

La règle entrante `Allow-HTTP` (port 80 depuis Internet) est nécessaire pour exposer l'application via le Load Balancer ; elle est acceptable au niveau réseau et se complète d'un WAF en production. La règle `Allow-SSH-Admin` (port 22) est restreinte à une IP `/32`, ce qui réduit fortement la surface de brute-force. Le NSG `nsg-shopeasy-dev-data` applique un `Deny-All-Inbound` et n'autorise que SQL (1433) depuis le subnet web : le subnet data n'est donc pas joignable depuis Internet.

### Synthèse sécurité

Les corrections minimales attendues sont en place : restriction SSH, accès public stockage désactivé, authentification Entra ID, alerte active, journalisation des scripts et absence d'action destructive sans confirmation. Le point ouvert restant est la **complétude des tags d'ownership**, traité côté FinOps/gouvernance.
