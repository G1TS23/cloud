# Captures d'écran du rendu — TP4 Monitoring, FinOps & Sécurité

> **Statut : captures réalisées** le 29/06/2026, à partir des sorties réelles des commandes exécutées sur l'environnement `rg-shopeasy-dev` (souscription *Azure for Students*, région `swedencentral`).
> Les images sont dans `tp4/screenshots/` et intégrées automatiquement en **Annexe C** du PDF par `scripts/build_rendu_tp4_pdf.py` (ordre alphabétique).
>
> Les captures sont rendues façon terminal à partir des sorties capturées, via `scripts/render_terminal_png.py`. Le nommage `atelier_NN-...` trace chaque preuve. Les sorties brutes correspondantes sont conservées dans `tp4/exports/`.

## Liste des captures (preuves d'exécution)

| # | Fichier | Atelier | Ce qui est visible |
|---|---|---|---|
| 1 | `atelier_02-monitor-law.png` | 2 | Création du Log Analytics Workspace `law-shopeasy-dev` + diagnostic settings (Activity Log et Storage vers LAW) |
| 2 | `atelier_03-vm-metrics.png` | 3 | État des VM, instance view, métriques CPU réelles (moyenne 1,76 %, max 8,3 %) |
| 3 | `atelier_04-alerts.png` | 4 | Action Group `ag-shopeasy-ops` + 3 alertes (CPU 70 %, disponibilité VM, modification NSG) |
| 4 | `atelier_05-dashboard.png` | 5 | Maquette documentée du tableau de bord d'exploitation (8 tuiles) |
| 5 | `atelier_06-finops.png` | 6 | Cost Management (coût par service), budget `budget-shopeasy-dev`, tags 16/16 |
| 6 | `atelier_07-security.png` | 7 | RBAC (Owner unique), règles NSG web/data, exposition stockage, Advisor |
| 7 | `atelier_08-activity-log.png` | 8 | Activity Log — opérations administratives réelles du TP |

## Valeurs réelles de l'environnement (29/06/2026)

- Resource Group : **rg-shopeasy-dev** — région **swedencentral** — 16 ressources (14 infra + workspace + action group)
- Log Analytics Workspace : **law-shopeasy-dev** (PerGB2018, rétention 30 j)
- Diagnostic settings : **diag-activitylog-shopeasy** (Activity Log → LAW), **diag-storage-shopeasy** (blob → LAW)
- VM : **vm-shopeasy-dev-web-1 / web-2** (`Standard_B2ts_v2`) — CPU moyen 1,76 %, max 8,3 %
- Action Group : **ag-shopeasy-ops** (`shopops`, ops-shopeasy@efrei.net)
- Alertes : **alert-cpu-70-shopeasy-web** (sév. 2), **alert-vm-availability-shopeasy-web** (sév. 1), **alert-nsg-change-shopeasy** (Activity Log), + **alert-cpu-high-vm-shopeasy-dev-web-1** (sév. 3, héritée TP3)
- Budget : **budget-shopeasy-dev** — 50 €/mois, alertes 80 % réel + 100 % prévisionnel
- Coût mois en cours : **1,19 €** (Virtual Network 0,92 ; Storage 0,26 ; VM 0,02)
- RBAC : 1 principal `User` avec rôle **Owner** au niveau souscription
- NSG web : HTTP 80 (Internet) + SSH 22 (`216.252.179.39/32`) — NSG data : SQL 1433 (subnet web) + Deny-All
- Storage : accès public blob **désactivé**, HTTPS only, TLS 1.2

## Reproduction

```bash
source tp3/variables.sh
bash scripts/azure-account.sh guard          # compte de formation
# Ateliers 2 à 8 : voir les commandes dans 01_compte_rendu_ateliers.md
# Régénération du rendu (PDF + ZIP) :
.venv-pdf/bin/python scripts/build_rendu_tp4_pdf.py
```

> Les fichiers Markdown de `tp4/livrables/` restent la **source éditable** ; le PDF en est la compilation. Les captures et exports bruts ne sont pas inclus dans le ZIP mais figurent en annexe du PDF.
