# TP Cloud Computing — Microsoft Azure

> **Auteurs :** Olivier Falahi & Paul Claverie
> **Formation :** M1 DEV — EFREI Bordeaux
> **Année :** 2025/2026
> **Bloc :** 4 — Optimisation du SI par l'apport du Cloud Computing
> **Parcours :** Mastère Dev Manager Full Stack

Ce dépôt regroupe les travaux pratiques du module **Cloud Computing Azure**. Cas fil rouge : migration de l'application de gestion de commandes **ShopEasy** vers Microsoft Azure.

| TP | Sujet | Statut | Supports | Livrables |
|---|---|---|---|---|
| **TP1** | Architecture cloud Azure (IaaS/PaaS, réseau, VM, LB, SQL, Storage, Monitor) | Terminé | [`tp1/sujet/`](tp1/sujet/) | [`tp1/`](tp1/) · [`dist/tp1/`](dist/tp1/) |
| **TP2** | Infrastructure as Code avec Terraform sur Azure | Terminé | [`tp2/sujet/`](tp2/sujet/) | [`tp2/`](tp2/) · [`dist/tp2/`](dist/tp2/) |
| **TP3** | Administration & automatisation Azure (CLI, Bash, Python, Monitor, FinOps) | Terminé | [`tp3/sujet/`](tp3/sujet/) | [`tp3/`](tp3/) · [`dist/tp3/`](dist/tp3/) |
| **TP4** | Monitoring, FinOps & sécurité Azure (Log Analytics, alertes, budget, RBAC, Activity Log) | Terminé | [`tp4/sujet/`](tp4/sujet/) | [`tp4/`](tp4/) · [`dist/tp4/`](dist/tp4/) |

> **Documentation :** index complet dans [`docs/README.md`](docs/README.md) — cours ([`docs/cours/`](docs/cours/)), sujets officiels (`tpN/sujet/`), **fiches de révision** ([`docs/revision/`](docs/revision/)) et **examens blancs** ([`docs/examens/`](docs/examens/)).

---

# Parcours pédagogique débutant

Progression numérotée pour comprendre ShopEasy et Terraform — voir [`docs/cours/README.md`](docs/cours/README.md).

| # | Cours |
|---|---|
| 01 | [Contexte ShopEasy — TP1 et TP2](docs/cours/01_contexte_shopeasy_tp1_et_tp2.md) |
| 02 | [Terraform — comprendre sans le code](docs/cours/02_terraform_comprendre_sans_le_code.md) |
| 03 | [`network.tf` ligne par ligne](docs/cours/03_network_tf_ligne_par_ligne.md) |
| 04 | [Quiz de validation](docs/cours/04_quiz_validation.md) |
| 05–08 | `security.tf`, `compute.tf`, `loadbalancer.tf`, `storage.tf` — *à venir* |

---

# TP1 — Architecture Cloud Azure (ShopEasy)

## Aperçu

Migration « lift-and-shift » de ShopEasy vers Azure : analyse de l'existant, choix des services, architecture cible, déploiement manuel via portail/CLI, supervision et gouvernance.

| Livrable | Fichier source | Description |
|---|---|---|
| Ateliers 1–15 | [`tp1/livrables/01_livrables_ateliers.md`](tp1/livrables/01_livrables_ateliers.md) | Analyse, choix services, déploiement, incidents, risques |
| Note DSI | [`tp1/livrables/02_note_DSI.md`](tp1/livrables/02_note_DSI.md) | Recommandations à la direction des SI |
| Architecture | [`tp1/architecture/`](tp1/architecture/) | Schéma Mermaid + draw.io (VNet, subnets, NSG, VM, LB, SQL, Storage) |
| Quiz | [`tp1/livrables/04_quiz_reponses.md`](tp1/livrables/04_quiz_reponses.md) | Réponses au questionnaire |
| Captures | [`tp1/screenshots/`](tp1/screenshots/) | Preuves portail Azure (ateliers 4–11) |
| Guide captures | [`tp1/livrables/05_captures_a_faire.md`](tp1/livrables/05_captures_a_faire.md) | Checklist des captures attendues |

### Architecture déployée

- **Région :** `swedencentral` (policy *Azure for Students* — `francecentral` interdite)
- **Resource Group :** `rg-shopeasy-dev`
- **Réseau :** VNet `10.10.0.0/16` — subnets `snet-web`, `snet-data`, `snet-admin`
- **Web :** 2 VM Linux Nginx (`Standard_B2ts_v2`) + Azure Load Balancer
- **Données :** Azure SQL Database (Serverless GP_S_Gen5_1) + Storage Account Blob privé
- **Sécurité :** NSG par subnet, Entra ID + RBAC, Azure Monitor

### Déploiement automatisé

```bash
az login
chmod +x scripts/deploy_shopeasy.sh
./scripts/deploy_shopeasy.sh          # déploie l'architecture
./scripts/deploy_shopeasy.sh cleanup  # supprime le Resource Group
```

### Archive Teams

| Fichier | Contenu |
|---|---|
| [`dist/tp1/Rendu_TP1_ShopEasy_Falahi_Claverie.zip`](dist/tp1/Rendu_TP1_ShopEasy_Falahi_Claverie.zip) | Rendu final (binôme) |
| [`dist/tp1/TP1_ShopEasy_Livrables_complet.pdf`](dist/tp1/TP1_ShopEasy_Livrables_complet.pdf) | Compilation PDF de tous les livrables |

---

# TP2 — Terraform & Infrastructure as Code

## Aperçu

Reprise du cas ShopEasy en **Infrastructure as Code** : workflow Terraform (`init → fmt → validate → plan → apply → destroy`), provider `azurerm`, variables, locals, outputs, state, tags et analyse de dérive. Extension autonomie retenue : **option A — subnet privé pour les données**.

| Support | Fichier |
|---|---|
| Index documentation | [`docs/README.md`](docs/README.md) |
| **Parcours pédagogique débutant** | [`docs/cours/README.md`](docs/cours/README.md) |
| Supports officiels TP2 | [`tp2/sujet/README.md`](tp2/sujet/README.md) |
| Consignes TP (PDF / Markdown) | [`tp2/sujet/TP2_Terraform_Azure.pdf`](tp2/sujet/TP2_Terraform_Azure.pdf) · [`tp2/sujet/TP2_Terraform_Azure.md`](tp2/sujet/TP2_Terraform_Azure.md) |
| Cours magistral (PDF / Markdown) | [`tp2/sujet/Cours_Magistral_TP2_Terraform_Azure.pdf`](tp2/sujet/Cours_Magistral_TP2_Terraform_Azure.pdf) · [`tp2/sujet/Cours_Magistral_TP2_Terraform_Azure.md`](tp2/sujet/Cours_Magistral_TP2_Terraform_Azure.md) |
| Fiche de révision | [`docs/revision/tp2/Fiche_revision_Terraform.md`](docs/revision/tp2/Fiche_revision_Terraform.md) |

### Projet Terraform

Code complet dans [`tp2/terraform/`](tp2/terraform/) : `versions.tf`, `providers.tf`, `variables.tf`, `locals.tf`, `network.tf`, `security.tf`, `compute.tf`, `loadbalancer.tf`, `storage.tf`, `outputs.tf`, `terraform.tfvars.example` et `templates/cloud-init.yml`.

```bash
cd tp2/terraform
cp terraform.tfvars.example terraform.tfvars   # renseigner subscription_id (FORMATION) + allowed_ssh_cidr
../../scripts/azure-account.sh login           # connexion compte student
../../scripts/azure-account.sh status          # DOIT être vert « FORMATION »
terraform init && terraform fmt && terraform validate
../../scripts/azure-account.sh guard && terraform plan
../../scripts/azure-account.sh guard && terraform apply
terraform output
../../scripts/azure-account.sh guard && terraform destroy   # obligatoire en fin de séance
```

> Région `swedencentral` et VM `Standard_B2ts_v2` (contraintes *Azure for Students*, paramétrées par variables).
> **Garde-fou multi-comptes :** `subscription_id` est épinglé dans `providers.tf` et `scripts/azure-account.sh guard` bloque tout déploiement hors compte de formation (utile pour ne pas viser un abonnement d'entreprise).

### Livrables

| Livrable | Fichier |
|---|---|
| Compte rendu des ateliers | [`tp2/livrables/01_compte_rendu_ateliers.md`](tp2/livrables/01_compte_rendu_ateliers.md) |
| Réponses au quiz (20 questions) | [`tp2/livrables/02_quiz_reponses.md`](tp2/livrables/02_quiz_reponses.md) |
| Analyse FinOps & sécurité | [`tp2/livrables/03_analyse_finops_securite.md`](tp2/livrables/03_analyse_finops_securite.md) |
| Mise en autonomie (option A) | [`tp2/livrables/04_autonomie_subnet_prive.md`](tp2/livrables/04_autonomie_subnet_prive.md) |
| Note technique | [`tp2/livrables/05_note_technique.md`](tp2/livrables/05_note_technique.md) |
| Index des captures + valeurs réelles | [`tp2/livrables/06_captures_a_faire.md`](tp2/livrables/06_captures_a_faire.md) |
| Preuves d'exécution (20 captures) | [`tp2/screenshots/`](tp2/screenshots/) |
| Récapitulatif de rendu | [`dist/tp2/README_RENDU_TP2.md`](dist/tp2/README_RENDU_TP2.md) |

### Rendu final

Le rendu est un **PDF unique** (note technique + ateliers + analyses + quiz + annexes + captures), livré dans une archive ZIP avec le **projet Terraform** et un **README txt** :

| Fichier | Contenu |
|---|---|
| [`dist/tp2/Rendu_TP2_ShopEasy_Terraform_Falahi_Claverie.zip`](dist/tp2/Rendu_TP2_ShopEasy_Terraform_Falahi_Claverie.zip) | PDF + `README_RENDU_TP2.md` + dossier `terraform/` |
| [`dist/tp2/TP2_ShopEasy_Terraform_Falahi_Claverie.pdf`](dist/tp2/TP2_ShopEasy_Terraform_Falahi_Claverie.pdf) | Document unique répondant à tout le TP2 |
| [`dist/tp2/README_RENDU_TP2.md`](dist/tp2/README_RENDU_TP2.md) | Mode d'emploi du rendu |

```bash
.venv-pdf/bin/python scripts/build_rendu_tp2_pdf.py   # régénère PDF + ZIP
```

---

# TP3 — Administration & Automatisation Azure

## Aperçu

Passage du **déploiement** (TP1/TP2) à l'**exploitation** de ShopEasy : inventaire, normalisation des tags, administration des VM, stockage opérationnel, supervision Azure Monitor, FinOps et sécurité, le tout via **Azure CLI**, des **scripts Bash** relançables et un **script Python** (SDK Azure). Toutes les commandes ont été exécutées sur l'infrastructure réellement redéployée (`rg-shopeasy-dev`, `swedencentral`).

## Mini-kit d'exploitation

Code dans [`tp3/`](tp3/) : variables, scripts Bash, script Python et exports.

```bash
source tp3/variables.sh                                   # RG, LOCATION, VM1/2, STORAGE...
./tp3/scripts/inventory.sh "$RG"                          # inventaire + compteurs + exports
./tp3/scripts/vm-power.sh "$RG" status                    # etat des VM (start/stop/deallocate)
./tp3/scripts/healthcheck.sh "$RG" "$STORAGE" operations  # 8 controles de sante
.venv/bin/python tp3/python/inventory.py tp3/exports/inventory.csv
```

> Les scripts sont robustes (`set -euo pipefail`), commentés, journalisés (`logs/vm-power.log`) et non destructifs sans confirmation (garde-fou anti-`prod`).

## Livrables

| Livrable | Fichier |
|---|---|
| Variables d'exploitation | [`tp3/variables.sh`](tp3/variables.sh) |
| Compte rendu des ateliers (1–12) | [`tp3/livrables/01_compte_rendu_ateliers.md`](tp3/livrables/01_compte_rendu_ateliers.md) |
| Réponses au quiz (20 questions) | [`tp3/livrables/02_quiz_reponses.md`](tp3/livrables/02_quiz_reponses.md) |
| Analyse FinOps & sécurité | [`tp3/livrables/03_analyse_finops_securite.md`](tp3/livrables/03_analyse_finops_securite.md) |
| Rapport d'exploitation | [`tp3/livrables/04_rapport_exploitation.md`](tp3/livrables/04_rapport_exploitation.md) |
| Note technique | [`tp3/livrables/05_note_technique.md`](tp3/livrables/05_note_technique.md) |
| Index des captures + valeurs réelles | [`tp3/livrables/06_captures_a_faire.md`](tp3/livrables/06_captures_a_faire.md) |
| Preuves d'exécution (10 captures) | [`tp3/screenshots/`](tp3/screenshots/) |

## Rendu final

| Fichier | Contenu |
|---|---|
| [`dist/tp3/Rendu_TP3_ShopEasy_Administration_Falahi_Claverie.zip`](dist/tp3/Rendu_TP3_ShopEasy_Administration_Falahi_Claverie.zip) | PDF + README + scripts + Python + exports |
| [`dist/tp3/TP3_ShopEasy_Administration_Falahi_Claverie.pdf`](dist/tp3/TP3_ShopEasy_Administration_Falahi_Claverie.pdf) | Document unique répondant à tout le TP3 (41 pages) |
| [`dist/tp3/README_RENDU_TP3.md`](dist/tp3/README_RENDU_TP3.md) | Mode d'emploi du rendu |

```bash
.venv-pdf/bin/python scripts/build_rendu_tp3_pdf.py   # régénère PDF + ZIP
```

---

# TP4 — Monitoring, FinOps & Sécurité Azure

## Aperçu

Passage de l'**administration** (TP3) au **pilotage** de ShopEasy : mise en place de l'observabilité (Log Analytics, diagnostic settings), d'alertes actionnables, d'une analyse FinOps (coûts, tags, budget), d'une revue de sécurité (RBAC, NSG, Advisor) et d'un audit Activity Log, débouchant sur une **note de recommandations DSI**. Toutes les commandes ont été exécutées sur l'infrastructure réelle (`rg-shopeasy-dev`, `swedencentral`).

## Dispositif mis en place

| Domaine | Réalisation Azure |
|---|---|
| Observabilité | Workspace `law-shopeasy-dev` (PerGB2018, 30 j) + diagnostics Activity Log & Storage |
| Alertes | Action Group `ag-shopeasy-ops` + 3 alertes (CPU 70 %, disponibilité VM, modification NSG) |
| FinOps | Budget `budget-shopeasy-dev` (50 €/mois, 80 %/100 %), tags sur 16/16 ressources |
| Sécurité | Revue RBAC (Owner unique), NSG web/data, exposition stockage, recommandations Advisor |
| Audit | Activity Log exporté vers le workspace, 3 événements interprétés |

## Supports officiels

| Support | Fichier |
|---|---|
| Sujet (PDF / Markdown) | [`tp4/sujet/TP4_MonitoringFinOpsSecurite_Azure.pdf`](tp4/sujet/TP4_MonitoringFinOpsSecurite_Azure.pdf) · [`.md`](tp4/sujet/TP4_MonitoringFinOpsSecurite_Azure.md) |
| Cours magistral (PDF / Markdown) | [`tp4/sujet/Cours_Magistral_TP4_Monitoring_FinOps_Securite_Azure.pdf`](tp4/sujet/Cours_Magistral_TP4_Monitoring_FinOps_Securite_Azure.pdf) · [`.md`](tp4/sujet/Cours_Magistral_TP4_Monitoring_FinOps_Securite_Azure.md) |
| Fiche de révision | [`docs/revision/tp4/Fiche_revision_Monitoring_FinOps_Securite.md`](docs/revision/tp4/Fiche_revision_Monitoring_FinOps_Securite.md) |

## Livrables

| Livrable | Fichier |
|---|---|
| Note de recommandations DSI | [`tp4/livrables/05_note_dsi.md`](tp4/livrables/05_note_dsi.md) |
| Compte rendu des ateliers (1–9) | [`tp4/livrables/01_compte_rendu_ateliers.md`](tp4/livrables/01_compte_rendu_ateliers.md) |
| Analyse FinOps & sécurité | [`tp4/livrables/03_analyse_finops_securite.md`](tp4/livrables/03_analyse_finops_securite.md) |
| Fiche d'audit Activity Log | [`tp4/livrables/04_fiche_audit_activity_log.md`](tp4/livrables/04_fiche_audit_activity_log.md) |
| Réponses au quiz (20 questions) | [`tp4/livrables/02_quiz_reponses.md`](tp4/livrables/02_quiz_reponses.md) |
| Index des captures + valeurs réelles | [`tp4/livrables/06_captures_a_faire.md`](tp4/livrables/06_captures_a_faire.md) |
| Preuves d'exécution (7 captures) | [`tp4/screenshots/`](tp4/screenshots/) |

## Rendu final

| Fichier | Contenu |
|---|---|
| [`dist/tp4/Rendu_TP4_ShopEasy_Monitoring_FinOps_Securite_Falahi_Claverie.zip`](dist/tp4/Rendu_TP4_ShopEasy_Monitoring_FinOps_Securite_Falahi_Claverie.zip) | PDF + README + variables + exports |
| [`dist/tp4/TP4_ShopEasy_Monitoring_FinOps_Securite_Falahi_Claverie.pdf`](dist/tp4/TP4_ShopEasy_Monitoring_FinOps_Securite_Falahi_Claverie.pdf) | Document unique répondant à tout le TP4 (31 pages) |
| [`dist/tp4/README_RENDU_TP4.md`](dist/tp4/README_RENDU_TP4.md) | Mode d'emploi du rendu |

```bash
.venv-pdf/bin/python scripts/build_rendu_tp4_pdf.py   # régénère PDF + ZIP
```

---

# Structure du projet

```
cloud/
├── README.md
├── LICENSE
├── .gitignore
├── docs/
│   ├── README.md                # Index de toute la documentation
│   ├── cours/                   # Parcours pédagogique débutant (numéroté)
│   │   ├── README.md
│   │   ├── 01_contexte_shopeasy_tp1_et_tp2.md
│   │   ├── 02_terraform_comprendre_sans_le_code.md
│   │   ├── 03_network_tf_ligne_par_ligne.md
│   │   └── 04_quiz_validation.md
│   ├── revision/                # Fiches de révision (PDF + Markdown)
│   │   ├── Fiche_synthese_globale_Cloud_Azure   # synthèse dédoublonnée des 4 TP
│   │   ├── Glossaire_acronymes_Cloud_Azure      # ~70 sigles du module
│   │   ├── tp1/Fiche_revision_Architecture_Cloud
│   │   ├── tp2/Fiche_revision_Terraform
│   │   ├── tp3/Fiche_revision_Administration_Azure
│   │   └── tp4/Fiche_revision_Monitoring_FinOps_Securite
│   └── examens/                 # Examens blancs (sujet + corrigé)
│       ├── Examen_blanc_Cloud_Azure             # cas MediTrack
│       └── Examen_blanc_2_Cloud_Azure           # cas EduStream
├── tp1/
│   ├── sujet/                   # Sujet officiel + cours magistral (PDF / Markdown)
│   │   ├── README.md
│   │   ├── Cours_Magistral_TP1_Azure.pdf
│   │   └── TP1_Architecture_Cloud_Azure.pdf
│   ├── livrables/
│   │   ├── 01_livrables_ateliers.md
│   │   ├── 02_note_DSI.md
│   │   ├── 04_quiz_reponses.md
│   │   └── 05_captures_a_faire.md
│   ├── architecture/
│   │   ├── README.md
│   │   ├── architecture.mmd
│   │   ├── architecture.drawio
│   │   └── architecture.png
│   └── screenshots/
│       └── atelier_*.png
├── tp2/
│   ├── sujet/                   # Sujet officiel + cours magistral (PDF / Markdown)
│   │   ├── README.md
│   │   ├── Cours_Magistral_TP2_Terraform_Azure.pdf / .md
│   │   └── TP2_Terraform_Azure.pdf / .md
│   ├── terraform/
│   │   ├── versions.tf · providers.tf · variables.tf · locals.tf
│   │   ├── network.tf · security.tf · compute.tf
│   │   ├── loadbalancer.tf · storage.tf · outputs.tf
│   │   ├── terraform.tfvars.example · .gitignore
│   │   └── templates/cloud-init.yml
│   ├── livrables/
│   │   ├── 01_compte_rendu_ateliers.md
│   │   ├── 02_quiz_reponses.md
│   │   ├── 03_analyse_finops_securite.md
│   │   ├── 04_autonomie_subnet_prive.md
│   │   ├── 05_note_technique.md
│   │   └── 06_captures_a_faire.md
│   └── screenshots/
│       └── atelier_*.png   (20 preuves d'exécution)
├── tp3/
│   ├── sujet/                   # Sujet officiel + cours magistral (PDF / Markdown)
│   ├── variables.sh             (variables d'exploitation)
│   ├── scripts/
│   │   ├── inventory.sh · vm-power.sh · healthcheck.sh
│   ├── python/
│   │   ├── inventory.py · requirements.txt
│   ├── exports/                 (resources.json/.tsv, inventory.csv, vms-*.txt)
│   ├── logs/vm-power.log
│   ├── livrables/
│   │   ├── 01_compte_rendu_ateliers.md
│   │   ├── 02_quiz_reponses.md
│   │   ├── 03_analyse_finops_securite.md
│   │   ├── 04_rapport_exploitation.md
│   │   ├── 05_note_technique.md
│   │   └── 06_captures_a_faire.md
│   └── screenshots/
│       └── atelier_*.png   (10 preuves d'exécution)
├── tp4/
│   ├── sujet/                   # Sujet officiel + cours magistral (PDF / Markdown)
│   ├── livrables/
│   │   ├── 01_compte_rendu_ateliers.md
│   │   ├── 02_quiz_reponses.md
│   │   ├── 03_analyse_finops_securite.md
│   │   ├── 04_fiche_audit_activity_log.md
│   │   ├── 05_note_dsi.md
│   │   └── 06_captures_a_faire.md
│   ├── exports/                 (cost-summary.json, activity-log-events.json, resources-tags.tsv, sorties ateliers)
│   └── screenshots/
│       └── atelier_*.png   (7 preuves d'exécution)
├── scripts/
│   ├── deploy_shopeasy.sh
│   ├── azure-account.sh         (garde-fou multi-comptes Azure)
│   ├── render_terminal_png.py   (captures terminal -> PNG)
│   ├── build_rendu_tp2_pdf.py
│   ├── build_rendu_tp3_pdf.py
│   └── build_rendu_tp4_pdf.py
└── dist/
    ├── tp1/
    │   ├── TP1_ShopEasy_Livrables_complet.pdf
    │   ├── Rendu_TP1_ShopEasy_Falahi_Claverie.zip
    │   └── *.pdf
    ├── tp2/
    │   ├── TP2_ShopEasy_Terraform_Falahi_Claverie.pdf
    │   ├── Rendu_TP2_ShopEasy_Terraform_Falahi_Claverie.zip
    │   └── README_RENDU_TP2.md
    ├── tp3/
    │   ├── TP3_ShopEasy_Administration_Falahi_Claverie.pdf
    │   ├── Rendu_TP3_ShopEasy_Administration_Falahi_Claverie.zip
    │   └── README_RENDU_TP3.md
    └── tp4/
        ├── TP4_ShopEasy_Monitoring_FinOps_Securite_Falahi_Claverie.pdf
        ├── Rendu_TP4_ShopEasy_Monitoring_FinOps_Securite_Falahi_Claverie.zip
        └── README_RENDU_TP4.md
```

---

# Ressources

| Sujet | Documentation |
|---|---|
| Azure (général) | [Microsoft Learn — Azure](https://learn.microsoft.com/fr-fr/azure/) |
| Well-Architected Framework | [Azure Architecture Center](https://learn.microsoft.com/fr-fr/azure/architecture/) |
| Terraform Azure | [Provider azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) |
| Azure CLI | [Référence az](https://learn.microsoft.com/fr-fr/cli/azure/) |

---

## Licence

[MIT](LICENSE) — Paul Claverie, 2026.
