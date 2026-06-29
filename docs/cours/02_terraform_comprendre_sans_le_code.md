# Cours 02 — Terraform : comprendre sans le code

> **Prérequis :** [Cours 01 — Contexte ShopEasy](01_contexte_shopeasy_tp1_et_tp2.md).  
> **Objectif :** comprendre Terraform (outils, workflow, state, variables) **avant** de lire les fichiers `.tf` ligne par ligne.  
> **Suite :** [Cours 03 — `network.tf` ligne par ligne](03_network_tf_ligne_par_ligne.md)

Guide pédagogique complétant la [Fiche de révision Terraform](../../tp2/sujet/Fiche_revision_Terraform.md).

**Cas fil rouge :** migration de l'application **ShopEasy** vers Microsoft Azure.  
**Auteurs du dépôt :** Olivier Falahi & Paul Claverie — EFREI Bordeaux, 2025/2026.

---

## 1. Le contexte : c'est quoi tout ça ?

### L'application ShopEasy

ShopEasy est une **application de gestion de commandes** (fictive, cas fil rouge du cours). Elle doit tourner dans le cloud Microsoft Azure au lieu d'un serveur physique en entreprise.

### Le cloud Azure, en une phrase

Azure, c'est un catalogue de **services informatiques à la demande** : machines virtuelles, réseaux, stockage de fichiers, bases de données… On les loue et on les configure via un site web (portail), des commandes (`az` CLI) ou du code (Terraform).

### TP1 vs TP2 : la différence essentielle

| | **TP1** | **TP2** |
|---|---|---|
| **Méthode** | À la main (portail Azure + script bash) | Par code (Terraform) |
| **Analogie** | Monter un meuble en suivant le PDF IKEA à la main | Avoir le plan IKEA en fichier texte, rejouable à l'identique |
| **Résultat** | Architecture ShopEasy complète | La même architecture, mais **décrite en fichiers `.tf`** |
| **Code** | [`tp1/`](../../tp1/) · [`scripts/deploy_shopeasy.sh`](../../scripts/deploy_shopeasy.sh) | [`tp2/terraform/`](../../tp2/terraform/) |

**L'idée du TP2 :** au TP1 on a appris *quoi* déployer (VNet, VM, Load Balancer…). Au TP2 on apprend *comment le décrire proprement* pour pouvoir le recréer, le modifier et le détruire de façon fiable.

---

## 2. Les outils utilisés

```
Vous (développeur)
    │
    ├── Azure CLI (`az login`)     → se connecter à Azure
    ├── Terraform                  → décrire et créer l'infra
    ├── scripts/azure-account.sh   → garde-fou (bon compte Azure)
    └── Git                        → versionner le code (pas le state !)
            │
            ▼
    Microsoft Azure (swedencentral)
    └── Resource Group rg-shopeasy-dev
        ├── Réseau (VNet, subnets, NSG)
        ├── 2 VM Linux + Nginx
        ├── Load Balancer
        └── Storage Account (fichiers)
```

| Outil | Rôle concret dans le projet |
|---|---|
| **Azure CLI** (`az`) | Connexion au compte étudiant Azure |
| **Terraform** | Lit les fichiers `.tf` et crée/modifie/supprime les ressources Azure |
| **Provider `azurerm`** | Plugin qui dit à Terraform comment parler à Azure |
| **Provider `random`** | Génère un suffixe aléatoire pour le nom du Storage Account (doit être unique mondialement) |
| **`terraform.tfvars`** | Paramètres personnels (subscription ID, IP SSH…) — **non versionné** |
| **`azure-account.sh guard`** | Bloque si on n'est pas sur le bon abonnement (évite un déploiement sur un compte pro par erreur) |

---

## 3. Ce qui a été concrètement construit

Architecture **réelle** du projet Terraform (`tp2/terraform/`) :

```
                    INTERNET
                        │
                        │ HTTP port 80
                        ▼
              ┌─────────────────────┐
              │  Load Balancer      │  ← IP publique principale
              │  (pip-shopeasy-dev-lb)│
              └─────────┬───────────┘
                        │ répartit le trafic
            ┌───────────┴───────────┐
            ▼                       ▼
    ┌──────────────┐        ┌──────────────┐
    │  VM web 1    │        │  VM web 2    │
    │  Ubuntu+Nginx│        │  Ubuntu+Nginx│
    │  snet-web    │        │  snet-web    │
    │  10.20.1.x   │        │  10.20.1.x   │
    └──────────────┘        └──────────────┘
            │                       │
            └───────────┬───────────┘
                        │ (futur SQL port 1433)
                        ▼
              ┌─────────────────────┐
              │  snet-data (privé)  │  ← Option A autonomie
              │  10.20.2.0/24       │     pas d'accès Internet
              │  (prévu pour SQL)   │
              └─────────────────────┘

    ┌─────────────────────┐
    │  Storage Account    │  ← stockage de documents (blob privé)
    │  (fichiers)         │
    └─────────────────────┘
```

### Ressources créées, fichier par fichier

| Fichier | Ce qu'il crée dans Azure |
|---|---|
| `network.tf` | Resource Group `rg-shopeasy-dev`, VNet `10.20.0.0/16`, 2 subnets (`snet-web`, `snet-data`) |
| `security.tf` | 2 pare-feux réseau (NSG) : un pour le web (HTTP + SSH), un pour les données (SQL uniquement depuis le web) |
| `compute.tf` | 2 VM Linux Ubuntu 22.04 avec Nginx, chacune avec une IP publique |
| `loadbalancer.tf` | Load Balancer qui distribue le trafic HTTP vers les 2 VM |
| `storage.tf` | Compte de stockage + conteneur `documents` (accès privé) |
| `outputs.tf` | Affiche l'IP du Load Balancer, les IP des VM, le nom du storage |
| `variables.tf` | Déclare les paramètres configurables |
| `locals.tf` | Calcule le préfixe `shopeasy-dev` et les tags communs |
| `providers.tf` | Configure la connexion au provider Azure |
| `versions.tf` | Versions minimales de Terraform et des providers |

---

## 4. Terraform expliqué depuis zéro

### L'idée centrale

Au lieu de cliquer dans le portail Azure « créer une VM », on écrit dans un fichier texte :

> « Il doit exister une VM Ubuntu nommée `vm-shopeasy-dev-web-1` dans le subnet web »

Terraform lit ce fichier, compare avec ce qui existe déjà dans Azure, et fait le nécessaire.

### Déclaratif vs impératif

| Approche | Principe | Exemple |
|---|---|---|
| **Impératif** (script bash TP1) | Liste les étapes une par une | « Étape 1 : crée le VNet. Étape 2 : crée le subnet… » |
| **Déclaratif** (Terraform) | Décrit l'état final voulu | « Voici l'infra que je veux. Débrouille-toi pour y arriver. » |

Si on relance `terraform apply` une 2e fois sans rien changer, Terraform ne recrée rien : tout est déjà là.

### Exemple concret tiré du projet

```hcl
resource "azurerm_resource_group" "main" {
  name     = "rg-${local.prefix}"      # → rg-shopeasy-dev
  location = var.location              # → swedencentral
  tags     = local.common_tags
}
```

Décryptage :

- `resource` → « je veux créer quelque chose »
- `"azurerm_resource_group"` → type Azure (un groupe de ressources)
- `"main"` → nom **interne** au code (pour y faire référence ailleurs)
- Le bloc `{ }` → les propriétés de la ressource

Quand une autre ressource écrit `azurerm_resource_group.main.name`, Terraform comprend : « il faut d'abord créer le Resource Group, puis la ressource qui en dépend ». C'est le **graphe de dépendances** automatique.

---

## 5. Le workflow exécuté (étape par étape)

Séquence complète (voir aussi le [`README.md`](../../README.md) à la racine) :

```bash
cd tp2/terraform
cp terraform.tfvars.example terraform.tfvars   # renseigner subscription_id + allowed_ssh_cidr
../../scripts/azure-account.sh login           # connexion Azure (compte FORMATION)
../../scripts/azure-account.sh status          # DOIT être vert « FORMATION »
terraform init      # ① télécharge les plugins Azure
terraform fmt       # ② met le code en forme
terraform validate  # ③ vérifie que le code est syntaxiquement correct
../../scripts/azure-account.sh guard && terraform plan   # ④ aperçu des changements
../../scripts/azure-account.sh guard && terraform apply  # ⑤ crée réellement dans Azure
terraform output    # ⑥ affiche les IP utiles
../../scripts/azure-account.sh guard && terraform destroy  # ⑦ tout supprime (fin de séance)
```

### Commandes Terraform — rappel

| Commande | Rôle | Analogie |
|---|---|---|
| `init` | Télécharge les providers, prépare le dossier | Installer les dépendances |
| `fmt` | Met en forme le code | Prettier |
| `validate` | Vérifie syntaxe et cohérence | Compiler |
| `plan` | **Prévisualise** créations / modifs / destructions | `git diff` avant commit |
| `apply` | Applique réellement | Déployer |
| `output` | Affiche les infos utiles (IP, noms…) | Le reçu |
| `destroy` | Supprime tout proprement | Nettoyer |

### Symboles du `plan` (à connaître)

| Symbole | Signification | Exemple |
|---|---|---|
| `+` | Va **créer** | Première fois : `+ azurerm_linux_virtual_machine.web[0]` |
| `~` | Va **modifier** | Changer la taille d'une VM |
| `-` | Va **supprimer** | `terraform destroy` |
| `-/+` | Va **détruire puis recréer** | ⚠️ La VM sera coupée un moment |

**Règle d'or :** toujours lire le `plan` avant `apply`. C'est comme un `git diff` avant un commit.

---

## 6. Variables, locals, outputs — avec les vraies valeurs du projet

### Variables = ce qui **entre** (paramètres)

```hcl
# variables.tf
variable "location" {
  default = "swedencentral"   # francecentral interdit sur Azure for Students
}

variable "vm_size" {
  default = "Standard_B2ts_v2"   # Standard_B1s indisponible sur la souscription Students
}

variable "allowed_ssh_cidr" {
  # VOTRE IP publique en /32, ex: "82.x.x.x/32"
  # → seul vous pouvez SSH sur les VM
}
```

Dans `terraform.tfvars` (fichier perso, **pas versionné**) :

```hcl
subscription_id     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
allowed_ssh_cidr    = "VOTRE.IP.PUBLIQUE/32"
ssh_public_key_path = "~/.ssh/id_rsa.pub"
```

### Locals = ce qui est **calculé** dans le projet

```hcl
# locals.tf
locals {
  prefix = "${var.project}-${var.environment}"   # → "shopeasy-dev"

  common_tags = {
    project     = "shopeasy"
    environment = "dev"
    owner       = "formation"
    managed_by  = "terraform"
    cost_center = "cloud-training"
  }
}
```

Grâce à `local.prefix`, tous les noms sont cohérents : `rg-shopeasy-dev`, `vnet-shopeasy-dev`, `vm-shopeasy-dev-web-1`…

### Outputs = ce que le projet **affiche** après déploiement

```hcl
output "load_balancer_public_ip" {
  value = azurerm_public_ip.lb.ip_address
}
```

Après `terraform apply`, `terraform output` donne l'IP pour ouvrir `http://X.X.X.X` dans le navigateur et voir la page Nginx « ShopEasy - serveur web 1 ».

### La règle d'or

| Concept | Rôle | Exemple projet |
|---|---|---|
| **Variable** | Entre (paramètre) | `location`, `vm_size`, `allowed_ssh_cidr` |
| **Local** | Calculé dans le projet | `prefix = "shopeasy-dev"`, tags communs |
| **Output** | Exposé après déploiement | IP du Load Balancer |

---

## 7. Le state — le carnet de bord de Terraform

Quand on fait `terraform apply`, Terraform crée un fichier **`terraform.tfstate`** qui contient :

> « Le code dit `azurerm_linux_virtual_machine.web[0]` → correspond à la VM réelle `vm-shopeasy-dev-web-1` d'ID `abc123...` dans Azure »

**Sans ce fichier**, Terraform ne sait plus ce qu'il a créé. Si on le perd, il ne peut plus gérer proprement les ressources.

| Règle | Pourquoi |
|---|---|
| **Jamais dans Git** | Contient des infos sensibles + conflits si 2 personnes modifient |
| En entreprise → **backend distant** | Stocké dans un Azure Storage Account, avec verrouillage |
| En formation (solo) | State local sur la machine, suffisant pour un TP |

Exemple de backend distant (entreprise, pas utilisé dans le TP) :

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstateprod001"
    container_name       = "tfstate"
    key                  = "shopeasy/dev/terraform.tfstate"
  }
}
```

---

## 8. Ce qui se passe « sous le capot » au déploiement

Ordre logique que Terraform calcule tout seul :

```
1. Resource Group (rg-shopeasy-dev)
       ↓
2. VNet + Subnets (snet-web, snet-data)
       ↓
3. NSG + associations aux subnets
       ↓
4. IPs publiques + cartes réseau (NIC)
       ↓
5. VM Linux (avec cloud-init → installe Nginx automatiquement)
       ↓
6. Load Balancer + règles + sonde HTTP
       ↓
7. Storage Account + conteneur documents
```

### Le cloud-init

Au démarrage de chaque VM, le fichier `templates/cloud-init.yml` est exécuté automatiquement :

- installe Nginx ;
- crée une page HTML « ShopEasy - serveur web 1 » (ou 2) ;
- démarre le serveur web.

C'est pour ça qu'après le déploiement, le Load Balancer sert une vraie page web sans SSH manuel sur les VM.

---

## 9. La sécurité dans le projet

| Élément | Ce que ça fait |
|---|---|
| **NSG web** | Autorise HTTP (port 80) depuis Internet + SSH (port 22) **uniquement depuis votre IP** |
| **NSG data** (option A) | Autorise SQL (port 1433) **uniquement depuis le subnet web** + refuse tout le reste |
| **Storage privé** | Le conteneur `documents` n'est pas accessible publiquement |
| **`subscription_id` épinglé** (`providers.tf`) | Terraform ne peut agir que sur l'abonnement formation |
| **`azure-account.sh guard`** | Double vérification avant `plan` / `apply` / `destroy` |

### Le drift (dérive)

Le **drift** = écart entre le code et la réalité Azure.

Si quelqu'un ouvre le port SSH à tout Internet **manuellement dans le portail**, au prochain `terraform plan` Terraform dira :

> « Le NSG ne correspond plus au code, je propose de remettre la règle d'origine »

**Règle :** le code est la source de vérité, pas le portail.

---

## 10. Contraintes Azure for Students

L'abonnement **Azure for Students** impose des restrictions :

| Paramètre cours | Valeur retenue | Raison |
|---|---|---|
| `francecentral` | `swedencentral` | Région interdite par la policy Students |
| `Standard_B1s` | `Standard_B2ts_v2` | Gabarit VM indisponible sur la souscription |

Adaptation via les variables dans `terraform.tfvars` — c'est exactement le principe de l'IaC : **un seul code, des paramètres différents selon l'environnement**.

---

## 11. Les 5 réflexes à retenir

1. **`plan` avant `apply`** — lire ce qui va changer, surtout les `-/+` (recréation = coupure)
2. **Le state ne va pas dans Git** — carnet de bord local (ou distant en équipe)
3. **Pas de secrets dans le code** — IP SSH et subscription ID dans `terraform.tfvars` (ignoré par Git)
4. **Tout est nommé et tagué** — `shopeasy-dev`, `managed_by = terraform`
5. **Ne pas modifier le portail à la main** — sinon drift, et Terraform ne sait plus qui a raison

---

## 12. Glossaire débutant

| Terme | En français simple |
|---|---|
| **IaC** | Décrire son infra en fichiers texte au lieu de cliquer dans un portail |
| **HCL** | Le langage des fichiers `.tf` (HashiCorp Configuration Language) |
| **Provider** | Plugin qui connecte Terraform à une plateforme (`azurerm` = Azure) |
| **Resource** | Un élément qu'on veut créer (VM, réseau, stockage…) |
| **Variable / Local / Output** | Entre / calculé / exposé |
| **State** | Lien entre le code et les ressources réelles dans Azure |
| **Backend** | Où est stocké le state (local ou Azure Storage) |
| **Plan / Apply** | Prévisualisation / application des changements |
| **Drift** | Écart entre le code et l'infrastructure réelle |
| **Module** | Bloc de code réutilisable (pas encore dans ce TP) |
| **NSG** | Pare-feu réseau Azure (règles entrantes/sortantes par subnet) |
| **FinOps** | Maîtrise des coûts cloud → `destroy` en fin de séance ! |

---

## 13. Terraform vs autres outils Azure

| Outil | Force | Limite | Quand l'utiliser |
|---|---|---|---|
| **Terraform** | Multi-cloud, modules, plan lisible | Gestion rigoureuse du state | Orga multi-cloud, IaC transverse |
| **ARM Templates** | Natif Azure, complet | JSON verbeux | Déploiements très proches de l'API Azure |
| **Bicep** | Natif Azure, lisible | Peu multi-cloud | Équipes 100 % Azure |
| **Scripts CLI** (`az`) | Simples, ponctuels | Peu déclaratifs | Dépannage, automatisations ciblées |

---

## 14. Pour aller plus loin dans le dépôt

| Objectif | Fichier |
|---|---|
| Index du parcours pédagogique | [`docs/cours/README.md`](README.md) |
| Index documentation | [`docs/README.md`](../README.md) |
| **`network.tf` ligne par ligne** | [Cours 03](03_network_tf_ligne_par_ligne.md) |
| Quiz de validation | [Cours 04](04_quiz_validation.md) |
| Fiche de révision (théorie condensée) | [`tp2/sujet/Fiche_revision_Terraform.md`](../../tp2/sujet/Fiche_revision_Terraform.md) |
| Consignes du TP2 | [`tp2/sujet/TP2_Terraform_Azure.md`](../../tp2/sujet/TP2_Terraform_Azure.md) |
| Cours magistral complet | [`tp2/sujet/Cours_Magistral_TP2_Terraform_Azure.md`](../../tp2/sujet/Cours_Magistral_TP2_Terraform_Azure.md) |
| Architecture visuelle (TP1) | [`tp1/architecture/architecture.mmd`](../../tp1/architecture/architecture.mmd) |
| Compte rendu des ateliers | [`tp2/livrables/01_compte_rendu_ateliers.md`](../../tp2/livrables/01_compte_rendu_ateliers.md) |
| Option subnet privé (autonomie) | [`tp2/livrables/04_autonomie_subnet_prive.md`](../../tp2/livrables/04_autonomie_subnet_prive.md) |
| Code Terraform complet | [`tp2/terraform/`](../../tp2/terraform/) |
| Commandes de déploiement | [`README.md`](../../README.md) |

---

## En résumé

> **Au TP1, on a appris à construire une maison à la main. Au TP2, on a écrit le plan de la maison dans des fichiers texte — et Terraform est l'entrepreneur qui lit le plan et construit (ou démolit) exactement ce qui est décrit.**

L'infrastructure devient un **actif logiciel** : versionné, relu, rejouable, destructible. C'est le cœur de l'Infrastructure as Code.

**Suite :** [Cours 03 — `network.tf` ligne par ligne vs bash TP1](03_network_tf_ligne_par_ligne.md)
