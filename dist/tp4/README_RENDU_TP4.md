# Rendu TP4 — Monitoring, FinOps & Sécurité Azure

> **Module :** Bloc 4 — Cloud Computing · Mastère Dev Manager Full Stack (EFREI)
> **Cas fil rouge :** ShopEasy · **Outils :** Azure CLI · Azure Monitor · Log Analytics · Cost Management
> **Auteurs :** Olivier Falahi & Paul Claverie · **Année :** 2025/2026

Ce document récapitule l'ensemble des livrables du TP4, conformément à la section 13 du sujet. Toutes les commandes ont été exécutées sur l'environnement ShopEasy réellement déployé (Resource Group `rg-shopeasy-dev`, région `swedencentral`, souscription *Azure for Students*).

## Fichier à rendre

> **Le rendu final est livré dans une archive ZIP** (PDF + variables + exports + README).

| Fichier | Description |
|---|---|
| `Rendu_TP4_ShopEasy_Monitoring_FinOps_Securite_Falahi_Claverie.zip` | Archive de rendu complète |
| `TP4_ShopEasy_Monitoring_FinOps_Securite_Falahi_Claverie.pdf` | Document unique répondant à tout le TP4 |
| `README_RENDU_TP4.md` | Ce mode d'emploi (inclus dans le ZIP) |

Le PDF et le ZIP sont générés via :

```bash
.venv-pdf/bin/python scripts/build_rendu_tp4_pdf.py
```

## Structure du ZIP

```
Rendu_TP4_ShopEasy_Monitoring_FinOps_Securite_Falahi_Claverie.zip
├── README_RENDU_TP4.md
├── TP4_ShopEasy_Monitoring_FinOps_Securite_Falahi_Claverie.pdf
├── variables.sh
└── exports/
    ├── cost-summary.json
    ├── activity-log-events.json
    └── resources-tags.tsv
```

## Contenu du PDF

1. Note de recommandations DSI (en tête)
2. Compte rendu des ateliers 1 à 9
3. Analyse FinOps & revue de sécurité (constats, actions, matrice de risques)
4. Fiche d'audit Activity Log (3 événements significatifs)
5. Quiz de validation (20 questions)
6. Annexe A — Arborescence du projet `tp4/`
7. Annexe B — Périmètre réutilisé et exports de preuve
8. Annexe C — Preuves d'exécution (7 captures)

## Dispositif mis en place sur Azure

| Domaine | Réalisation |
|---|---|
| Observabilité | Log Analytics Workspace `law-shopeasy-dev` + diagnostic settings (Activity Log, Storage) |
| Alertes | Action Group `ag-shopeasy-ops` + 3 alertes (CPU 70 %, disponibilité VM, modification NSG) |
| FinOps | Budget `budget-shopeasy-dev` (50 €/mois, 80 %/100 %), tags sur 16/16 ressources |
| Sécurité | Revue RBAC, NSG, exposition stockage, recommandations Advisor |
| Audit | Activity Log exporté vers le workspace, 3 événements interprétés |

## Reproduire l'exploitation

```bash
source tp3/variables.sh                       # RG, LOCATION, VM1/2, STORAGE, etc.
bash scripts/azure-account.sh guard           # compte de formation (garde-fou)
# Ateliers 2 à 8 : commandes détaillées dans tp4/livrables/01_compte_rendu_ateliers.md
.venv-pdf/bin/python scripts/build_rendu_tp4_pdf.py   # régénère PDF + ZIP
```

> Les fichiers Markdown de `tp4/livrables/` restent la **source éditable** ; le PDF en est la compilation pour le rendu.
