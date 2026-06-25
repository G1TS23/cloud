# Captures d'écran à faire pour le rendu — TP2 Terraform

> À réaliser **après `terraform apply`** sur une souscription de **formation / sandbox** (jamais un abonnement d'entreprise).
> Récupérer d'abord les valeurs réelles avec `terraform output` (IP du Load Balancer, IP des VM, nom du Storage).
>
> **Nommage des fichiers :** déposer les images dans `tp2/screenshots/` en respectant les noms ci-dessous (préfixe `atelier_NN-...`). Le script `scripts/build_rendu_tp2_pdf.py` les intègre automatiquement dans l'annexe « Preuves d'exécution » du PDF, dans l'ordre alphabétique des noms.

## Captures terminal (workflow Terraform) — section 20, points 3 et 5

| # | Fichier à déposer | Commande à capturer | Ce qui doit être visible |
|---|---|---|---|
| 1 | `atelier_02-init.png` | `terraform init` | « Terraform has been successfully initialized! » + providers `azurerm`/`random` téléchargés |
| 2 | `atelier_02-validate.png` | `terraform validate` | « Success! The configuration is valid. » |
| 3 | `atelier_03-plan.png` | `terraform plan` | Récapitulatif `Plan: N to add, 0 to change, 0 to destroy` |
| 4 | `atelier_04-apply.png` | `terraform apply` | « Apply complete! Resources: N added » |
| 5 | `atelier_09-output.png` | `terraform output` | `load_balancer_public_ip`, `web_vm_public_ips`, `resource_group_name`, `storage_account_name` |
| 6 | `atelier_06-state-list.png` *(optionnel)* | `terraform state list` | Liste des ressources gérées (VM, NIC, IP, NSG, LB, Storage) |

## Captures portail Azure — section 20, point 4

> Portail : https://portal.azure.com — Resource Group **`rg-shopeasy-dev`** — Région **Sweden Central**.

| # | Fichier à déposer | Où, dans le portail | Ce qui doit être visible |
|---|---|---|---|
| 7 | `atelier_04-portail-rg.png` | `rg-shopeasy-dev` → *Vue d'ensemble* + onglet *Étiquettes* | Région Sweden Central + tags `project`, `environment`, `owner`, `managed_by`, `cost_center` |
| 8 | `atelier_05-vnet-subnets.png` | `vnet-shopeasy-dev` → *Sous-réseaux* | Espace `10.20.0.0/16` + `snet-web` (10.20.1.0/24) et `snet-data` (10.20.2.0/24) |
| 9 | `atelier_05-nsg-web.png` | `nsg-shopeasy-dev-web` → *Règles de trafic entrant* | `Allow-HTTP` (80, Internet) et `Allow-SSH-Admin` (22, votre IP /32) |
| 10 | `atelier_05-nsg-data.png` *(option A)* | `nsg-shopeasy-dev-data` → *Règles de trafic entrant* | `Allow-SQL-From-Web` (1433 depuis 10.20.1.0/24) + `Deny-All-Inbound` |
| 11 | `atelier_06-vms.png` | RG filtré sur *Virtual machine* | `vm-shopeasy-dev-web-1` et `-web-2` en **Running** |
| 12 | `atelier_07-lb-backend.png` | `lb-shopeasy-dev-web` → *Pools de back-end* + *Sondes d'intégrité* | backend `backend-web` avec 2 cibles + sonde `http-probe` (HTTP:80 `/`) |
| 13 | `atelier_08-storage.png` | `shopeasydevdocs...` → *Configuration* puis *Conteneurs* | TLS 1.2, accès public désactivé, container `documents` **privé**, versioning activé |

## Captures navigateur — section 20, point 5

| # | Fichier à déposer | URL | Ce qui doit être visible |
|---|---|---|---|
| 14 | `atelier_09-page-lb.png` | `http://<IP_LB>` | Page « ShopEasy - serveur web 1 » ou « 2 » (rafraîchir → alternance) |
| 15 | `atelier_06-page-vm1.png` *(optionnel)* | `http://<IP_VM_1>` | Page « ShopEasy - serveur web 1 » |
| 16 | `atelier_06-page-vm2.png` *(optionnel)* | `http://<IP_VM_2>` | Page « ShopEasy - serveur web 2 » |

## Captures dérive et nettoyage — ateliers 11 et 14

| # | Fichier à déposer | Commande / action | Ce qui doit être visible |
|---|---|---|---|
| 17 | `atelier_11-drift-plan.png` | tag manuel `manual_change=true` sur le RG, puis `terraform plan` | Terraform détecte l'écart et propose de **retirer** le tag (`~ update in-place`) |
| 18 | `atelier_14-destroy.png` | `terraform destroy` | « Destroy complete! Resources: N destroyed » (ou RG vide dans le portail) |

---

## Minimum noté

Les **7 captures obligatoires** de la section 20 : init/validate/plan/apply/output (1→5), portail RG+ressources (7), page web via LB (14).

Pour viser le maximum sur la grille (workflow 4 pts, compute 4 pts, drift 2 pts, qualité 3 pts), ajouter les captures 8 à 13, 17 et 18.

## Rappel valeurs (à compléter après `terraform output`)

- Région : **Sweden Central** · VM : **Standard_B2ts_v2**
- IP LB : `________` · VM1 : `________` · VM2 : `________`
- Storage : `shopeasydevdocs________`
