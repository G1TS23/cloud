# TP2 Terraform — Analyse coût, sécurité et maintenabilité

> Atelier 13 du sujet. Cas ShopEasy, environnement de dev sur `swedencentral`.

---

## 1. Analyse FinOps (17.1)

| Ressource | Coût relatif | Risque de surcoût | Optimisation proposée |
|---|---|---|---|
| **VM Linux (×2)** | Élevé (poste principal) | VM surdimensionnées ou laissées allumées 24/7 | Gabarit burstable (`B2ts_v2`), arrêt/désallocation hors usage, auto-shutdown, `terraform destroy` en fin de séance |
| **IP publiques (×3 : 2 VM + 1 LB)** | Faible à modéré | IP `Standard` statiques facturées même inutilisées ; multiplication inutile | Supprimer les IP publiques des VM (accès via LB + Bastion) → ne garder que l'IP du LB |
| **Load Balancer** | Modéré (SKU Standard + règles) | Règles/IP facturées en continu | Mutualiser un seul LB pour plusieurs services ; détruire en dev hors usage |
| **Storage Account** | Faible (volume de démo) | Croissance non maîtrisée des données | Tier `Standard`/`LRS` en dev, lifecycle policy, surveiller la volumétrie |
| **Versioning Blob** | Faible mais cumulatif | Accumulation des versions antérieures facturées | Lifecycle : transition Cool/Archive puis suppression des versions > N jours |
| **Disques managés (OS)** | Faible (`Standard_LRS`) | Disques orphelins après suppression de VM | `Standard_LRS` en dev, nettoyage des disques non rattachés, destroy complet |

**Leviers FinOps appliqués dans le projet :** taille de VM adaptée (variable `vm_size`), tags de coût (`cost_center`), réplication `LRS` (la moins chère), et destruction reproductible via `terraform destroy`.

---

## 2. Analyse de sécurité (17.2)

| Risque | Cause possible | Impact | Correction |
|---|---|---|---|
| **SSH trop ouvert** | Règle NSG en `0.0.0.0/0` sur le port 22 | Brute-force, intrusion sur les VM | SSH restreint à `allowed_ssh_cidr` (/32) ; en prod, Azure Bastion / suppression du SSH public |
| **State exposé** | `terraform.tfstate` commité ou partagé sans contrôle | Fuite de secrets et de la topologie | `.gitignore` du state en local ; backend `azurerm` distant chiffré + RBAC en équipe |
| **Storage public** | `container_access_type` en `blob`/`container` | Fuite de documents métier (RGPD) | Container `private` (appliqué) ; accès via SAS/identités gérées uniquement |
| **Tags absents** | Ressources créées sans `tags` | Coûts non imputables, gouvernance impossible | `common_tags` appliqué à toutes les ressources taguables ; Azure Policy d'enforcement |
| **Secrets dans Git** | Mot de passe / clé en clair dans `.tf` ou `tfvars` versionné | Compromission d'identifiants | Aucun secret en dur ; seule la clé SSH **publique** est référencée par chemin ; `terraform.tfvars` ignoré ; Key Vault en prod |
| **Modification manuelle** | Changement dans le portail hors Terraform | Dérive (drift), perte de reproductibilité | Changements par PR + `plan`/`apply` contrôlés ; `plan` périodique de détection ; Azure Policy |

---

## 3. Maintenabilité (17.3)

1. **Rendre le projet réutilisable pour la recette ?**
   Les valeurs sont déjà paramétrées par variables. Il suffit d'un jeu de valeurs par environnement : soit un fichier `recette.tfvars` (`environment = "recette"`, `vm_size`, CIDR…) appliqué via `terraform apply -var-file=recette.tfvars`, soit des **workspaces** Terraform, soit (mieux) un **backend** avec une `key` distincte par environnement. Le `prefix` (`shopeasy-<env>`) garantit des noms de ressources uniques par environnement.

2. **Quelles variables ajouter ?**
   `vm_count` (nombre de VM web), `os_disk_type`, `account_replication_type` (LRS/GRS selon l'env), `tags` additionnels (ex. `expiration`), un booléen `enable_public_ip_on_vm` pour couper les IP publiques en prod, et éventuellement `address_space`/préfixes déjà variabilisés.

3. **Quels fichiers pourraient devenir des modules ?**
   - `network.tf` + `security.tf` → **module `network`** (RG, VNet, subnets, NSG).
   - `compute.tf` → **module `compute`** (VM, NIC, IP, cloud-init).
   - `loadbalancer.tf` → **module `loadbalancer`**.
   - `storage.tf` → **module `storage`**.
   Le projet racine se réduirait alors à des appels de modules paramétrés par environnement.

4. **Quelles validations automatiques en CI/CD ?**
   `terraform fmt -check`, `terraform validate`, `terraform plan` posté en commentaire de PR, **analyse de sécurité statique** (`tflint`, `tfsec`/`checkov`), **estimation de coût** (`infracost`), scan de secrets (gitleaks), puis `apply` gated par approbation manuelle sur les environnements sensibles.
