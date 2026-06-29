# TP4 — Compte rendu des ateliers (Monitoring, FinOps & Sécurité)

> Cas fil rouge : **ShopEasy**. Environnement réel `rg-shopeasy-dev` (souscription *Azure for Students*, région `swedencentral`), exploité le 29/06/2026 via Azure CLI 2.87.
>
> Le sujet utilise `francecentral` dans ses exemples ; l'infrastructure ShopEasy est déployée à `swedencentral` (policy *Azure for Students*), les commandes ont donc été adaptées. Chaque atelier se termine par la référence de la capture qui en constitue la preuve d'exécution.

---

## Atelier 1 — Cadrer les indicateurs d'exploitation

Avant d'outiller, on définit **quoi** surveiller. Le tableau suivant priorise les indicateurs pertinents pour ShopEasy, par domaine.

| Domaine | Indicateur | Seuil proposé | Justification |
|---|---|---|---|
| Disponibilité | Disponibilité VM (VM Availability) | < 1 (KO) | Détecte une VM tombée : impact direct sur le service web ShopEasy. |
| Disponibilité | Disponibilité applicative HTTP via le Load Balancer | échec sonde > 2 min | La sonde LB reflète l'expérience réelle de l'utilisateur, pas seulement l'état machine. |
| Performance | CPU moyen des VM | > 70 % sur 5 min | Anticipe la saturation et le sous-dimensionnement avant dégradation. |
| Performance | Réseau In/Out, disque | pic anormal vs baseline | Identifie une charge inhabituelle ou une attaque. |
| Capacité | Stockage consommé (Storage) | > 80 % du quota cible | Anticipe la croissance et le coût du Storage Account. |
| Coût | Coût mensuel et prévisionnel (Cost Management) | > 80 % du budget | Détecte une dérive financière avant la facture. |
| Sécurité | Modifications RBAC / règles NSG (Activity Log) | tout changement | Trace une élévation de privilèges ou une ouverture de port. |
| Exploitation | Alertes critiques ouvertes, temps de résolution | toute alerte sév. 1 | Pilote l'efficacité opérationnelle de l'équipe. |

**Réponses aux questions guidées.**

1. **Pourquoi pas seulement le CPU ?** Le CPU ne dit rien de la disponibilité réelle, des coûts, de la sécurité ou de la saturation disque/réseau. Une VM peut avoir un CPU faible tout en étant injoignable, ou en accumulant une dérive de coûts.
2. **Saturation :** CPU, mémoire, disque (IOPS/espace), file d'attente réseau, connexions base.
3. **Dérive de coûts :** coût par service, coût par tag, coût prévisionnel et budget consommé dans Cost Management.
4. **Signaux sécurité :** changements RBAC, modifications de règles NSG, ports exposés à Internet, accès public au stockage, recommandations Advisor/Defender.
5. **Incident / alerte / recommandation :** un **incident** est un événement avéré dégradant le service ; une **alerte** est un signal automatique déclenché sur un seuil (qui peut précéder ou révéler un incident) ; une **recommandation** est une amélioration proposée (Advisor) sans urgence immédiate.

**Livrable.** Tableau d'indicateurs priorisés ci-dessus.

---

## Atelier 2 — Préparer l'environnement Azure Monitor

Mise en place de la base d'observabilité : un Log Analytics Workspace et des diagnostic settings vers ce workspace.

```bash
source tp3/variables.sh   # RG, LOCATION, VM1/2, STORAGE...

# Log Analytics Workspace (rétention 30 jours)
az monitor log-analytics workspace create \
  --resource-group "$RG" --workspace-name law-shopeasy-dev \
  --location "$LOCATION" --retention-time 30

# Activity Log -> LAW (audit des opérations administratives)
az monitor diagnostic-settings subscription create \
  --name diag-activitylog-shopeasy --location "$LOCATION" --workspace "$LAW_ID" \
  --logs '[{"category":"Administrative","enabled":true},{"category":"Security","enabled":true}, ...]'

# Storage (blob) -> LAW (lecture/écriture/suppression + transactions)
az monitor diagnostic-settings create \
  --name diag-storage-shopeasy --resource "$SA_ID/blobServices/default" --workspace "$LAW_ID" \
  --logs '[StorageRead, StorageWrite, StorageDelete]' --metrics '[Transaction]'
```

**Résultat réel.**

| Élément | Valeur |
|---|---|
| Workspace | `law-shopeasy-dev` — SKU `PerGB2018`, rétention 30 j, état `Succeeded` |
| Diagnostic Activity Log | `diag-activitylog-shopeasy` (Administrative, Security, Alert, Policy) → LAW |
| Diagnostic Storage blob | `diag-storage-shopeasy` (3 catégories de logs + Transaction/Capacity) → LAW |

Ressources identifiées dans le périmètre : 2 VM, 2 NSG (web/data), 1 Storage Account, 1 VNet (2 subnets), 1 Load Balancer, 3 IP publiques, 2 NIC. La base Azure SQL n'est pas déployée dans l'environnement actuel (cf. note technique).

**Livrable.** Capture `atelier_02-monitor-law.png`.

---

## Atelier 3 — Superviser les machines virtuelles

```bash
az vm list -g "$RG" --show-details -o table
az vm get-instance-view -g "$RG" -n "$VM1" -o table
az monitor metrics list --resource "$VM1_ID" --metric "Percentage CPU" \
  --interval PT5M --aggregation Average Maximum
```

**Résultat réel** (VM redémarrées pour la mesure ; elles étaient désallouées depuis le TP3 par souci FinOps) :

| VM | État | CPU moyen / max (5 min) | Risque observé | Action proposée |
|---|---|---|---|---|
| `vm-shopeasy-dev-web-1` | Running, `Standard_B2ts_v2` | 1,76 % / 8,3 % | Sous-utilisation (CPU très bas) | Confirme que `B2ts_v2` suffit ; candidat à l'extinction hors usage. |
| `vm-shopeasy-dev-web-2` | Running, `Standard_B2ts_v2` | ~2 % | Idem | Idem ; désallouer hors période d'activité. |

**Réponses aux questions d'analyse.**

1. **Dimensionnement :** correct, voire surdimensionné au repos (CPU < 10 %). La taille `B2ts_v2` (burstable) est adaptée à une charge web faible et variable.
2. **Métriques suffisantes ?** Non : le CPU/réseau/disque indiquent la santé machine mais pas la santé applicative (codes HTTP, temps de réponse, erreurs Nginx).
3. **Métriques manquantes :** taux d'erreur HTTP, latence applicative, disponibilité de l'endpoint, logs Nginx centralisés.
4. **Disponibilité réelle utilisateur :** ajouter une sonde HTTP (Load Balancer health probe déjà présent, ou un test de disponibilité Application Insights / URL ping) et exporter les logs applicatifs vers le LAW.

**Recommandations d'exploitation (≥ 2) :** (1) activer **VM Insights** et l'agent Azure Monitor pour collecter mémoire et logs invité (recommandé par Advisor) ; (2) **désallouer** les VM hors période d'activité via `tp3/scripts/vm-power.sh` pour réduire le coût compute.

**Livrable.** Capture `atelier_03-vm-metrics.png`.

---

## Atelier 4 — Créer des alertes opérationnelles

Création d'un Action Group et de trois alertes (deux métriques + une Activity Log), au-delà du minimum de deux demandé.

```bash
az monitor action-group create -g "$RG" --name ag-shopeasy-ops \
  --short-name shopops --action email EquipeOps ops-shopeasy@efrei.net

# Alerte CPU > 70 % (sév. 2) sur les 2 VM
az monitor metrics alert create --name alert-cpu-70-shopeasy-web -g "$RG" \
  --scopes "$VM1_ID" "$VM2_ID" --region "$LOCATION" \
  --condition "avg Percentage CPU > 70" --window-size 5m --evaluation-frequency 1m \
  --severity 2 --action "$AG_ID"

# Alerte VM indisponible (sév. 1)
az monitor metrics alert create --name alert-vm-availability-shopeasy-web -g "$RG" \
  --scopes "$VM1_ID" "$VM2_ID" --region "$LOCATION" \
  --condition "avg VmAvailabilityMetric < 1" --severity 1 --action "$AG_ID"

# Alerte Activity Log : modification d'une règle NSG
az monitor activity-log alert create --name alert-nsg-change-shopeasy -g "$RG" \
  --condition category=Administrative and operationName=Microsoft.Network/networkSecurityGroups/securityRules/write \
  --action-group "$AG_ID"
```

**Fiches d'alerte (résultat réel).**

| Alerte | Ressource cible | Condition / seuil | Criticité | Destinataire | Procédure de réaction |
|---|---|---|---|---|---|
| `alert-cpu-70-shopeasy-web` | 2 VM web | CPU moyen > 70 % / 5 min | Sév. 2 (moyenne) | `ag-shopeasy-ops` (email) | Vérifier charge et logs, envisager montée en taille ou scale-out. |
| `alert-vm-availability-shopeasy-web` | 2 VM web | VM Availability < 1 | Sév. 1 (haute) | `ag-shopeasy-ops` | Redémarrer la VM, escalader, analyser l'incident. |
| `alert-nsg-change-shopeasy` | RG (Activity Log) | écriture d'une règle NSG | — (audit) | `ag-shopeasy-ops` | Vérifier la légitimité du changement, rollback si non autorisé. |
| `alert-cpu-high-vm-shopeasy-dev-web-1` | VM web-1 | CPU > 80 % (héritée TP3) | Sév. 3 | — | Surveillance historique. |

**Réponses aux questions d'analyse.**

1. **Seuils trop bas :** trop de déclenchements non actionnables → fatigue d'alerte, l'équipe finit par ignorer les notifications.
2. **Seuils trop hauts :** détection tardive, l'incident est déjà visible des utilisateurs quand l'alerte se déclenche.
3. **Documenter l'action :** une alerte sans procédure laisse l'équipe sans savoir quoi faire ; elle doit pointer vers un runbook.
4. **Éviter la fatigue d'alerte :** distinguer critique / avertissement / information, ne mettre en alerte que l'actionnable, le reste va au dashboard.

**Livrable.** Capture `atelier_04-alerts.png`.

---

## Atelier 5 — Construire un tableau de bord d'exploitation

Faute de déploiement d'un dashboard portail partagé, une **maquette documentée** précise les tuiles attendues et la décision que chacune facilite (option explicitement autorisée par le sujet).

| Tuile | Source | Décision facilitée |
|---|---|---|
| État des VM | Azure Monitor | Détecter une indisponibilité |
| CPU des VM | Metrics | Identifier une surcharge |
| Trafic réseau In/Out | Metrics | Repérer un pic anormal |
| Stockage consommé | Storage metrics | Anticiper capacité et coût |
| Coûts du mois / budget | Cost Management | Piloter le budget (1,19 € / 50 €) |
| Alertes récentes | Azure Monitor Alerts | Prioriser les incidents |
| Journaux / Activity Log | Log Analytics (`law-shopeasy-dev`) | Auditer « qui a fait quoi » |
| État base de données | (tuile prévue si Azure SQL ajouté) | Détecter saturation base |

Chaque tuile répond à une question de pilotage (disponibilité, charge, coût, incident, audit) plutôt qu'à une simple courbe technique.

**Livrable.** Maquette `atelier_05-dashboard.png`.

---

## Atelier 6 — Analyse FinOps

```bash
# Coût par service (mois en cours)
az rest --method post --url ".../Microsoft.CostManagement/query?api-version=2023-03-01" --body @cost-query.json

# Tags de gouvernance sur toutes les ressources
az resource tag --ids <id> --is-incremental \
  --tags Application=ShopEasy Environment=dev Owner=equipe-cloud CostCenter=DSI-Cloud Criticality=<low|medium|high>

# Budget mensuel 50 € avec alertes 80 % (réel) et 100 % (prévisionnel)
az rest --method put --url ".../Microsoft.Consumption/budgets/budget-shopeasy-dev?api-version=2021-10-01" --body @budget-body.json
```

**Résultat réel — coût par service (mois en cours, EUR) :**

| Service | Coût (€) |
|---|---|
| Virtual Network | 0,9186 |
| Storage | 0,2582 |
| Virtual Machines | 0,0159 |
| Bandwidth / Azure Monitor / Load Balancer | ~0,0000 |
| **Total** | **1,1928** |

> Le coût compute est très faible car les VM sont **désallouées** la majeure partie du temps depuis le TP3 (levier FinOps déjà appliqué). Le poste principal est ici le réseau (IP publiques réservées).

**Gouvernance des tags :** 16/16 ressources taguées `Application`, `Environment`, `Owner`, `CostCenter`, `Criticality` (criticité `high` pour VM/LB/Storage/disques, `medium` pour réseau, `low` pour IP/NIC).

**Budget :** `budget-shopeasy-dev`, 50 €/mois, notifications à **80 % du coût réel** et **100 % du coût prévisionnel** vers `ops-shopeasy@efrei.net`.

L'analyse FinOps détaillée (≥ 5 constats, ≥ 5 actions) figure dans [`03_analyse_finops_securite.md`](03_analyse_finops_securite.md).

**Réponses aux questions d'analyse.**

1. **Pourquoi plus cher que prévu ?** Facturation à la consommation, ressources oubliées, IP/disques orphelins, surdimensionnement, absence de budget.
2. **À arrêter hors usage :** les VM web (environnement dev), via désallocation.
3. **Tags indispensables :** sans tags, impossible de ventiler ni de refacturer les coûts par application/équipe/environnement.
4. **Réduction vs optimisation :** réduire = baisser la dépense ; optimiser = maximiser la valeur par euro (bon dimensionnement, bon service, sans dégrader le SLA).

**Livrable.** Capture `atelier_06-finops.png`.

---

## Atelier 7 — Revue de sécurité Azure

```bash
az role assignment list --scope "/subscriptions/$SUB" -o table
az network nsg rule list -g "$RG" --nsg-name nsg-shopeasy-dev-web -o table
az network nsg rule list -g "$RG" --nsg-name nsg-shopeasy-dev-data -o table
az storage account show -g "$RG" -n "$STORAGE" --query "{PublicBlob:allowBlobPublicAccess, ...}"
az advisor recommendation list -o table
```

**Résultats réels.**

- **RBAC :** un seul principal (`User`) avec le rôle **Owner** au niveau souscription, hérité par le RG → pas de séparation des rôles ni de moindre privilège.
- **NSG web :** `Allow-HTTP` (80, Internet) + `Allow-SSH-Admin` (22, restreint à `216.252.179.39/32`). SSH n'est pas ouvert à tout Internet.
- **NSG data :** `Allow-SQL-From-Web` (1433 depuis `10.20.1.0/24`) + `Deny-All-Inbound`. Subnet données correctement isolé.
- **Storage :** accès public blob **désactivé**, HTTPS obligatoire, TLS 1.2 minimum.
- **Advisor :** recommandations *High Availability* (zone redundancy storage, disques en zone, migration série D, VMSS Flex), *Security* (Guest Configuration extension à installer), *Operational Excellence* (activer VM Insights), *Soft Delete* blob.

La matrice de risques complète (≥ 5 risques) figure dans [`03_analyse_finops_securite.md`](03_analyse_finops_securite.md).

**Livrable.** Capture `atelier_07-security.png`.

---

## Atelier 8 — Audit des changements et Activity Log

```bash
az monitor activity-log list -g "$RG" --start-time <-2h> \
  --query "[?status.value=='Succeeded']"
```

L'Activity Log (désormais aussi exporté vers `law-shopeasy-dev`) trace les opérations réalisées pendant le TP : création du workspace, du budget, de l'action group, des alertes, application des tags. La fiche d'audit détaillée (3 événements significatifs interprétés) figure dans [`04_fiche_audit_activity_log.md`](04_fiche_audit_activity_log.md).

**Réponses aux questions d'analyse.**

1. **Importance :** l'Activity Log répond à « qui a fait quoi, quand » sur les ressources — indispensable pour l'audit et le post-mortem d'incident.
2. **Log technique vs log d'activité :** un log technique vient de la ressource (Nginx, OS) ; le log d'activité vient du plan de gestion Azure (opérations ARM).
3. **Information manquante :** parfois le contexte applicatif (corrélation avec un log technique) ou la justification métier du changement.
4. **Contrôle interne DSI :** exporter l'Activity Log vers Log Analytics permet des requêtes KQL, des revues périodiques et la preuve de conformité.

**Livrable.** Capture `atelier_08-activity-log.png`.

---

## Atelier 9 — Plan d'amélioration avant production

La note de recommandations DSI complète figure dans [`05_note_dsi.md`](05_note_dsi.md) (contexte, état, monitoring, FinOps, sécurité, risques résiduels, plan d'action priorisé, conclusion).

---

## Synthèse de conformité (grille du sujet)

| Critère (sujet) | Couverture | Preuve |
|---|---|---|
| Indicateurs de supervision | Atelier 1 | Tableau priorisé |
| Alertes configurées | 3 alertes + Action Group | `atelier_04-alerts.png` |
| Dashboard / maquette | Maquette documentée | `atelier_05-dashboard.png` |
| Analyse FinOps | ≥ 5 constats / actions | `03_…` + `atelier_06-finops.png` |
| Analyse sécurité | Matrice ≥ 5 risques | `03_…` + `atelier_07-security.png` |
| Activity Log | 3 événements interprétés | `04_…` + `atelier_08-activity-log.png` |
| Note DSI | Note structurée | `05_note_dsi.md` |
