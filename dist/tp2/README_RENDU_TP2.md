# Rendu TP2 — Infrastructure as Code avec Terraform sur Azure

> **Module :** Bloc 4 — Cloud Computing · Mastère Dev Manager Full Stack (EFREI)
> **Cas fil rouge :** ShopEasy · **Outil :** Terraform · **Cloud :** Microsoft Azure
> **Auteurs :** Olivier Falahi & Paul Claverie · **Année :** 2025/2026

Ce document récapitule l'ensemble des livrables du TP2, conformément à la section 20 du sujet.

---

## Fichier à rendre

> **Le rendu final est un PDF unique, livré dans une archive ZIP.**

| Fichier | Description |
|---|---|
| [`Rendu_TP2_ShopEasy_Terraform_Falahi_Claverie.zip`](Rendu_TP2_ShopEasy_Terraform_Falahi_Claverie.zip) | **Archive de rendu** (contient uniquement le PDF) |
| [`TP2_ShopEasy_Terraform_Falahi_Claverie.pdf`](TP2_ShopEasy_Terraform_Falahi_Claverie.pdf) | **Document unique** répondant à tout le TP2 : note technique, compte rendu des ateliers, analyses FinOps & sécurité, mise en autonomie, quiz, arborescence et code source Terraform intégral |

Le PDF est généré à partir des sources Markdown et du code Terraform via :

```bash
.venv-pdf/bin/python scripts/build_rendu_tp2_pdf.py
cd dist/tp2 && zip -j Rendu_TP2_ShopEasy_Terraform_Falahi_Claverie.zip TP2_ShopEasy_Terraform_Falahi_Claverie.pdf
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
| 06 | [Captures à faire](../../tp2/livrables/06_captures_a_faire.md) | Checklist des preuves d'exécution à produire après `terraform apply` |

### 3. Supports — [`docs/tp2/`](../../docs/tp2/)

Sujet et cours magistral disponibles en PDF **et** transcription Markdown, plus la fiche de révision Terraform.

---

## Correspondance avec la grille d'évaluation (32 pts)

| Critère (pts) | Où c'est traité |
|---|---|
| Structure du projet Terraform (3) | `tp2/terraform/` — fichiers séparés par responsabilité |
| Provider, variables et tags (3) | `versions.tf`, `providers.tf`, `variables.tf`, `locals.tf` |
| Réseau Azure (4) | `network.tf`, `security.tf` (RG, VNet, subnets, NSG) |
| Compute (4) | `compute.tf` + `templates/cloud-init.yml` (2 VM, web validé) |
| Load Balancer (3) | `loadbalancer.tf` (IP, backend pool, probe, règle) |
| Storage (2) | `storage.tf` (compte privé, container, versioning) |
| Workflow Terraform (4) | `01_compte_rendu_ateliers.md` (init/fmt/validate/plan/apply/output/destroy) |
| Analyse sécurité et FinOps (4) | `03_analyse_finops_securite.md` |
| Analyse de dérive (2) | `01_compte_rendu_ateliers.md` (atelier 11) |
| Qualité des livrables (3) | Ce récapitulatif + note technique + diagrammes |

---

## Preuves d'exécution (captures)

> **État actuel : aucune capture intégrée.** Le déploiement doit être réalisé sur une **souscription de formation / sandbox** (jamais un abonnement d'entreprise). Tant que `tp2/screenshots/` est vide, le PDF est généré sans l'Annexe C et le signale honnêtement.

Procédure complète et nommage des fichiers : [`tp2/livrables/06_captures_a_faire.md`](../../tp2/livrables/06_captures_a_faire.md).

Captures minimales (section 20) à produire après `terraform apply` :

1. `terraform init` (initialisation réussie) ;
2. `terraform validate` (configuration valide) ;
3. `terraform plan` (ressources à créer) ;
4. `terraform apply` (application réussie) ;
5. `terraform output` (IP du Load Balancer, etc.) ;
6. portail Azure : `rg-shopeasy-dev` et ses ressources ;
7. navigateur : page ShopEasy via l'IP du Load Balancer ;
8. `terraform plan` après modification manuelle (preuve de dérive).

**Workflow automatique :** déposer les PNG dans [`tp2/screenshots/`](../../tp2/screenshots/) en respectant le nommage du guide, puis relancer le script de génération. Les captures apparaissent alors automatiquement en **Annexe C — Preuves d'exécution** du PDF, et l'introduction passe en état « conforme ».

---

## Reproduire le déploiement

```bash
cd tp2/terraform
cp terraform.tfvars.example terraform.tfvars   # renseigner allowed_ssh_cidr (votre IP /32)
az login
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
# ... vérifications ...
terraform destroy   # nettoyage obligatoire en fin de séance
```
