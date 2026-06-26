# TP Cloud Computing — Microsoft Azure

> **Auteurs :** Olivier Falahi & Paul Claverie
> **Formation :** M1 DEV — EFREI Bordeaux
> **Année :** 2025/2026
> **Bloc :** 4 — Optimisation du SI par l'apport du Cloud Computing
> **Parcours :** Mastère Dev Manager Full Stack

Ce dépôt regroupe les travaux pratiques du module **Cloud Computing Azure**. Cas fil rouge : migration de l'application de gestion de commandes **ShopEasy** vers Microsoft Azure.

| TP | Sujet | Statut | Supports | Livrables |
|---|---|---|---|---|
| **TP1** | Architecture cloud Azure (IaaS/PaaS, réseau, VM, LB, SQL, Storage, Monitor) | Terminé | [`docs/tp1/`](docs/tp1/) | [`tp1/`](tp1/) · [`dist/tp1/`](dist/tp1/) |
| **TP2** | Infrastructure as Code avec Terraform sur Azure | Terminé | [`docs/tp2/`](docs/tp2/) | [`tp2/`](tp2/) · [`dist/tp2/`](dist/tp2/) |

> **Documentation :** index complet dans [`docs/README.md`](docs/README.md) — supports officiels (`tp1/`, `tp2/`) et parcours débutant ([`docs/cours/`](docs/cours/)).

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
| Supports officiels TP2 | [`docs/tp2/README.md`](docs/tp2/README.md) |
| Consignes TP (PDF / Markdown) | [`docs/tp2/TP2_Terraform_Azure.pdf`](docs/tp2/TP2_Terraform_Azure.pdf) · [`docs/tp2/TP2_Terraform_Azure.md`](docs/tp2/TP2_Terraform_Azure.md) |
| Cours magistral (PDF / Markdown) | [`docs/tp2/Cours_Magistral_TP2_Terraform_Azure.pdf`](docs/tp2/Cours_Magistral_TP2_Terraform_Azure.pdf) · [`docs/tp2/Cours_Magistral_TP2_Terraform_Azure.md`](docs/tp2/Cours_Magistral_TP2_Terraform_Azure.md) |
| Fiche de révision | [`docs/tp2/Fiche_revision_Terraform.md`](docs/tp2/Fiche_revision_Terraform.md) |

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
│   ├── tp1/                     # Supports officiels TP1 (PDF)
│   │   ├── README.md
│   │   ├── Cours_Magistral_TP1_Azure.pdf
│   │   └── TP1_Architecture_Cloud_Azure.pdf
│   └── tp2/                     # Supports officiels TP2 (PDF + MD)
│       ├── README.md
│       ├── Cours_Magistral_TP2_Terraform_Azure.pdf / .md
│       ├── TP2_Terraform_Azure.pdf / .md
│       └── Fiche_revision_Terraform.pdf / .md
├── tp1/
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
├── scripts/
│   ├── deploy_shopeasy.sh
│   ├── azure-account.sh         (garde-fou multi-comptes Azure)
│   ├── render_terminal_png.py   (captures terminal -> PNG)
│   └── build_rendu_tp2_pdf.py
└── dist/
    ├── tp1/
    │   ├── TP1_ShopEasy_Livrables_complet.pdf
    │   ├── Rendu_TP1_ShopEasy_Falahi_Claverie.zip
    │   └── *.pdf
    └── tp2/
        ├── TP2_ShopEasy_Terraform_Falahi_Claverie.pdf
        ├── Rendu_TP2_ShopEasy_Terraform_Falahi_Claverie.zip
        └── README_RENDU_TP2.md
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
