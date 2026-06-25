# Rendu TP2 — Infrastructure as Code avec Terraform sur Azure

> **Module :** Bloc 4 — Cloud Computing · Mastère Dev Manager Full Stack (EFREI)
> **Cas fil rouge :** ShopEasy · **Outil :** Terraform · **Cloud :** Microsoft Azure
> **Auteurs :** Olivier Falahi & Paul Claverie · **Année :** 2025/2026

Ce document récapitule l'ensemble des livrables du TP2, conformément à la section 20 du sujet.

---

## Fichier à rendre

> **Le rendu final est livré dans une archive ZIP** (PDF + projet Terraform + README).

| Fichier | Description |
|---|---|
| [`Rendu_TP2_ShopEasy_Terraform_Falahi_Claverie.zip`](Rendu_TP2_ShopEasy_Terraform_Falahi_Claverie.zip) | **Archive de rendu** : PDF, `README_RENDU_TP2.md`, dossier `terraform/` |
| [`TP2_ShopEasy_Terraform_Falahi_Claverie.pdf`](TP2_ShopEasy_Terraform_Falahi_Claverie.pdf) | Document unique répondant à tout le TP2 |
| [`README_RENDU_TP2.md`](README_RENDU_TP2.md) | Mode d'emploi du rendu (inclus dans le ZIP) |

Le PDF et le ZIP sont générés via :

```bash
.venv-pdf/bin/python scripts/build_rendu_tp2_pdf.py
```

Structure du ZIP :

```
Rendu_TP2_ShopEasy_Terraform_Falahi_Claverie.zip
├── README_RENDU_TP2.md
├── TP2_ShopEasy_Terraform_Falahi_Claverie.pdf
└── terraform/
    ├── versions.tf · providers.tf · variables.tf · locals.tf
    ├── network.tf · security.tf · compute.tf
    ├── loadbalancer.tf · storage.tf · outputs.tf
    ├── terraform.tfvars.example · .gitignore
    └── templates/cloud-init.yml
```

> Les fichiers Markdown de `tp2/livrables/` restent la **source éditable** ; le PDF en est la compilation pour le rendu.

---

## Contenu du rendu

### 1. Projet Terraform — [`tp2/terraform/`](../../tp2/terraform/)

Arborescence complète et fichiers `.tf` :

| Fichier | Rôle |
|---|---|
| `versions.tf` | Versions Terraform et providers (`azurerm ~> 4.0`, `random ~> 3.6`) |
| `providers.tf` | Configuration du provider `azurerm` |
| `variables.tf` | Variables d'entrée paramétrables |
| `locals.tf` | Préfixe de nommage et tags communs |
| `network.tf` | Resource Group, VNet, subnets web et data |
| `security.tf` | NSG web (HTTP + SSH restreint) et NSG data (SQL privé) |
| `compute.tf` | 2 VM Linux (`count`), NIC, IP publiques, cloud-init |
| `loadbalancer.tf` | Load Balancer, backend pool, probe, règle HTTP |
| `storage.tf` | Storage Account privé + container + versioning |
| `outputs.tf` | IP du Load Balancer, IP des VM, nom du RG, nom du Storage |
| `terraform.tfvars.example` | Modèle de valeurs (sans secret) |
| `templates/cloud-init.yml` | Provisioning Nginx au démarrage |

### 2. Livrables écrits — [`tp2/livrables/`](../../tp2/livrables/)

| # | Livrable | Couverture |
|---|---|---|
| 01 | [Compte rendu des ateliers](../../tp2/livrables/01_compte_rendu_ateliers.md) | Réponses aux questions guidées (ateliers 4, 5, 6, 7, 8, 10, 11, 12) + checklist technique (atelier 9) + analyse de dérive (atelier 11) |
| 02 | [Réponses au quiz](../../tp2/livrables/02_quiz_reponses.md) | 20 questions de validation (section 21) |
| 03 | [Analyse FinOps & sécurité](../../tp2/livrables/03_analyse_finops_securite.md) | Tableaux FinOps et sécurité complétés + maintenabilité (atelier 13) |
| 04 | [Mise en autonomie — option A](../../tp2/livrables/04_autonomie_subnet_prive.md) | Subnet privé données : modification, fichiers impactés, risques (atelier 19) |
| 05 | [Note technique](../../tp2/livrables/05_note_technique.md) | Synthèse des choix, conventions, adaptations |
| 06 | [Captures réalisées](../../tp2/livrables/06_captures_a_faire.md) | Index des 20 preuves d'exécution + valeurs réelles du déploiement |

### 3. Supports — [`docs/tp2/`](../../docs/tp2/)

Sujet et cours magistral disponibles en PDF **et** transcription Markdown, plus la fiche de révision Terraform.

---

## Correspondance avec la grille d'évaluation (32 pts)

| Critère (pts) | Où c'est traité |
|---|---|
| Structure du projet Terraform (3) | `tp2/terraform/` — fichiers séparés par responsabilité |
| Provider, variables et tags (3) | `versions.tf`, `providers.tf`, `variables.tf`, `locals.tf` |
| Réseau Azure (4) | `network.tf`, `security.tf` (RG, VNet, subnets, NSG) |
| Compute (4) | `compute.tf` + cloud-init (2 VM Running, accès web validé — captures `atelier_06-vms`, `atelier_09-page-lb`) |
| Load Balancer (3) | `loadbalancer.tf` + capture `atelier_07-lb-backend` + round-robin `atelier_09-curl-lb` |
| Storage (2) | `storage.tf` + capture `atelier_08-storage` (container privé, versioning) |
| Workflow Terraform (4) | init/validate/plan/apply/output/destroy — captures `atelier_02` à `atelier_14` (Annexe C) |
| Analyse sécurité et FinOps (4) | `03_analyse_finops_securite.md` |
| Analyse de dérive (2) | `01_compte_rendu_ateliers.md` (atelier 11) + capture `atelier_11-drift-plan` |
| Qualité des livrables (3) | Ce récapitulatif + note technique + 20 captures en Annexe C |

---

## Preuves d'exécution (captures)

> **État : déploiement réalisé et 20 captures intégrées en Annexe C du PDF.** Infrastructure déployée le 25/06/2026 sur *Azure for Students* (`swedencentral`), 24 ressources créées puis détruites (`terraform destroy`). Valeurs réelles : LB `20.91.219.236`, VM web-1 `4.223.225.195`, VM web-2 `4.223.111.127`, Storage `shopeasydevdocsbhvsip`.

Index complet et valeurs : [`tp2/livrables/06_captures_a_faire.md`](../../tp2/livrables/06_captures_a_faire.md). Images dans [`tp2/screenshots/`](../../tp2/screenshots/).

Captures couvertes (section 20 + ateliers + grille) :

1. `terraform init` (initialisation réussie) ;
2. `terraform validate` (configuration valide) ;
3. `terraform plan` (ressources à créer) ;
4. `terraform apply` (application réussie) ;
5. `terraform output` (IP du Load Balancer, etc.) ;
6. portail Azure : `rg-shopeasy-dev` et ses ressources ;
7. navigateur : page ShopEasy via l'IP du Load Balancer ;
8. `terraform plan` après modification manuelle (preuve de dérive).

9. portail Azure : tags du RG, VNet/subnets, NSG web et data, VM en Running, LB backend pool, Storage privé ;
10. `terraform state list` et `terraform destroy` (workflow complet) ;
11. répartition de charge prouvée par `curl` (round-robin web 1 / web 2).

**Workflow automatique :** les PNG de [`tp2/screenshots/`](../../tp2/screenshots/) sont intégrés automatiquement en **Annexe C — Preuves d'exécution** du PDF par `scripts/build_rendu_tp2_pdf.py` (régénérer après tout ajout d'image).

---

## Reproduire le déploiement (avec garde-fou multi-comptes)

> **Sécurité compte :** ce projet est protégé contre un déploiement accidentel sur un abonnement d'entreprise par **deux mécanismes** :
> 1. `tp2/terraform/providers.tf` épingle `subscription_id = var.subscription_id` — Terraform agit **uniquement** sur l'abonnement déclaré dans `terraform.tfvars`, jamais sur le compte par défaut d'`az` ;
> 2. `scripts/azure-account.sh` affiche/bascule le compte actif et **refuse** (`guard`) si ce n'est pas le compte de formation.

```bash
# 1. Se connecter au compte STUDENT (s'ajoute aux comptes déjà connectés)
./scripts/azure-account.sh login

# 2. Basculer sur le lab et VÉRIFIER (banderole verte = OK pour déployer)
./scripts/azure-account.sh use "<nom-souscription-student>"
./scripts/azure-account.sh status

# 3. Récupérer l'ID du lab et le coller dans terraform.tfvars
az account show --query id -o tsv

cd tp2/terraform
cp terraform.tfvars.example terraform.tfvars
#   -> subscription_id  = "<ID student récupéré ci-dessus>"
#   -> allowed_ssh_cidr = "<votre IP publique>/32"   (curl ifconfig.me)

# 4. Workflow Terraform, précédé du garde-fou à chaque action sensible
terraform init && terraform fmt && terraform validate
../../scripts/azure-account.sh guard && terraform plan
../../scripts/azure-account.sh guard && terraform apply
terraform output     # noter IP LB, IP VM1/VM2, nom du Storage
# ... captures (voir tp2/livrables/06_captures_a_faire.md) ...
../../scripts/azure-account.sh guard && terraform destroy   # nettoyage obligatoire
```

> **En entreprise :** un simple `./scripts/azure-account.sh status` affiche en rouge « ENTREPRISE — NE PAS DÉPLOYER », et `guard` renvoie une erreur bloquante. Même en cas d'oubli, l'épinglage `subscription_id` empêche Terraform de cibler Floa.
