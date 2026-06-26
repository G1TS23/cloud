# Cours 03 — `network.tf` ligne par ligne vs bash TP1

> **Prérequis :** [Cours 01](01_contexte_shopeasy_tp1_et_tp2.md) et [Cours 02](02_terraform_comprendre_sans_le_code.md).  
> **Objectif :** comprendre chaque bloc de [`tp2/terraform/network.tf`](../../tp2/terraform/network.tf) en le reliant **commande par commande** au script bash du TP1 [`scripts/deploy_shopeasy.sh`](../../scripts/deploy_shopeasy.sh).  
> **Suite :** Cours 05 — `security.tf` (à venir)

---

## 1. Rôle de `network.tf`

Ce fichier pose les **fondations réseau** de ShopEasy dans Azure :

1. Un **dossier** pour regrouper toutes les ressources → Resource Group
2. Un **réseau privé virtuel** → VNet
3. Des **sous-réseaux** pour séparer les fonctions → subnets web et data

Rien d'autre : pas de VM, pas de pare-feu, pas de Load Balancer. C'est le premier étage de la maison.

### Fichiers liés (à connaître avant de lire le code)

| Fichier | Ce qu'il apporte à `network.tf` |
|---|---|
| [`variables.tf`](../../tp2/terraform/variables.tf) | `location`, `vnet_address_space`, `web_subnet_prefix`, `data_subnet_prefix` |
| [`locals.tf`](../../tp2/terraform/locals.tf) | `local.prefix` (= `shopeasy-dev`), `local.common_tags` |

---

## 2. Vue d'ensemble : bash TP1 vs Terraform TP2

### Script bash — ateliers 4 et 5

```bash
# Atelier 4
az group create --name "${RG}" --location "${LOCATION}" --tags ...

# Atelier 5
az network vnet create \
  --resource-group "${RG}" --name "${VNET}" \
  --address-prefix 10.10.0.0/16 \
  --subnet-name snet-web --subnet-prefix 10.10.1.0/24

az network vnet subnet create ... --name snet-data --address-prefixes 10.10.2.0/24
az network vnet subnet create ... --name snet-admin --address-prefixes 10.10.3.0/24
```

### Terraform — `network.tf` (4 blocs `resource`)

```hcl
azurerm_resource_group.main      →  az group create
azurerm_virtual_network.main     →  az network vnet create
azurerm_subnet.web               →  subnet web (créé avec le vnet ou après)
azurerm_subnet.data              →  az network vnet subnet create (data)
```

### Différences importantes à noter

| Point | TP1 (bash) | TP2 (Terraform) |
|---|---|---|
| Plage VNet | `10.10.0.0/16` | `10.20.0.0/16` (variable, évite conflit si les deux coexistent) |
| Subnet web | `10.10.1.0/24` | `10.20.1.0/24` |
| Subnet data | `10.10.2.0/24` | `10.20.2.0/24` |
| Subnet admin | `10.10.3.0/24` ✅ | ❌ absent du TP2 |
| Région | `francecentral` dans le script (adapté en `swedencentral` au déploiement) | `swedencentral` via `var.location` |

Même **logique**, paramètres légèrement différents.

---

## 3. Bloc 1 — Resource Group

### Code Terraform

```hcl
resource "azurerm_resource_group" "main" {
  name     = "rg-${local.prefix}"
  location = var.location
  tags     = local.common_tags
}
```

### Équivalent bash TP1

```bash
az group create \
  --name "rg-shopeasy-dev" \
  --location "swedencentral" \
  --tags projet=shopeasy environnement=dev ...
```

### Décryptage ligne par ligne

| Ligne HCL | Signification | Valeur réelle |
|---|---|---|
| `resource` | « Je veux une ressource Azure » | — |
| `"azurerm_resource_group"` | Type = groupe de ressources Azure | — |
| `"main"` | Nom **interne** au code (pas le nom Azure) | Référencé ailleurs : `.main.name` |
| `name = "rg-${local.prefix}"` | Nom dans le portail Azure | `rg-shopeasy-dev` |
| `location = var.location` | Région Azure | `swedencentral` |
| `tags = local.common_tags` | Étiquettes de gouvernance | `project`, `environment`, `managed_by`… |

### Pourquoi un Resource Group ?

C'est le **conteneur** de tout le projet ShopEasy. Supprimer le RG = supprimer toutes les ressources dedans. Utile pour le nettoyage (`destroy` ou `az group delete`).

### Ce que Terraform fait de plus que le bash

- Si le RG existe déjà avec le bon nom → **ne recrée pas**.
- Si vous changez un tag → `plan` montre `~` (modification), pas de recréation.

---

## 4. Bloc 2 — Virtual Network (VNet)

### Code Terraform

```hcl
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${local.prefix}"
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}
```

### Équivalent bash TP1

```bash
az network vnet create \
  --resource-group "rg-shopeasy-dev" \
  --name "vnet-shopeasy-dev" \
  --address-prefix 10.10.0.0/16 \
  --subnet-name "snet-web" \
  --subnet-prefix 10.10.1.0/24
```

> **Note :** la commande `az network vnet create` du TP1 crée le VNet **et** le premier subnet en une fois. En Terraform, le VNet et chaque subnet sont des **ressources séparées** (plus lisible, plus flexible).

### Décryptage ligne par ligne

| Ligne HCL | Équivalent bash / idée | Valeur réelle |
|---|---|---|
| `name = "vnet-${local.prefix}"` | `--name "vnet-shopeasy-dev"` | `vnet-shopeasy-dev` |
| `address_space = [var.vnet_address_space]` | `--address-prefix 10.10.0.0/16` | `10.20.0.0/16` |
| `location = azurerm_resource_group.main.location` | hérite la région du RG | `swedencentral` |
| `resource_group_name = azurerm_resource_group.main.name` | `--resource-group "rg-shopeasy-dev"` | lien de dépendance auto |
| `tags = local.common_tags` | `--tags ...` | tags communs |

### C'est quoi un VNet ?

Un **réseau privé virtuel** dans Azure. Les VM, subnets et Load Balancer internes vivent dedans. Les adresses IP (`10.20.x.x`) ne sont **pas** routables sur Internet — c'est voulu (RFC 1918).

### La référence `azurerm_resource_group.main.name`

Quand Terraform lit cette ligne, il comprend :

> « Le VNet a besoin du Resource Group. Je crée d'abord le RG, puis le VNet. »

Pas besoin d'écrire `depends_on` — c'est une **dépendance implicite**.

---

## 5. Bloc 3 — Subnet web

### Code Terraform

```hcl
resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.web_subnet_prefix]
}
```

### Équivalent bash TP1

```bash
# Créé en même temps que le VNet :
az network vnet create ... --subnet-name "snet-web" --subnet-prefix 10.10.1.0/24
```

### Décryptage ligne par ligne

| Ligne HCL | Équivalent bash | Valeur réelle |
|---|---|---|
| `"azurerm_subnet"` | sous-réseau dans un VNet | — |
| `"web"` | nom interne Terraform | — |
| `name = "snet-web"` | `--subnet-name "snet-web"` | `snet-web` |
| `virtual_network_name = ...main.name` | `--vnet-name "vnet-shopeasy-dev"` | dépend du VNet |
| `address_prefixes = [var.web_subnet_prefix]` | `--subnet-prefix 10.10.1.0/24` | `10.20.1.0/24` |

### Rôle du subnet web

C'est le **quartier des serveurs web**. Les 2 VM ShopEasy (`compute.tf`) seront branchées ici. Ce subnet est exposé indirectement via le Load Balancer et les IP publiques des VM.

---

## 6. Bloc 4 — Subnet data (option A autonomie)

### Code Terraform

```hcl
resource "azurerm_subnet" "data" {
  name                 = "snet-data"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.data_subnet_prefix]
}
```

### Équivalent bash TP1

```bash
az network vnet subnet create \
  --resource-group "rg-shopeasy-dev" \
  --vnet-name "vnet-shopeasy-dev" \
  --name "snet-data" \
  --address-prefixes 10.10.2.0/24
```

### Rôle du subnet data

Zone **privée** prévue pour une future base de données (Azure SQL). Aucune VM web ici. Le pare-feu (`security.tf`) n'autorisera que le port SQL (1433) depuis le subnet web.

### Ce que le TP2 n'a pas (par rapport au TP1)

Le bash TP1 crée aussi :

```bash
az network vnet subnet create ... --name "snet-admin" --address-prefixes 10.10.3.0/24
```

Subnet **admin** pour un futur bastion / accès admin isolé. Non implémenté dans le Terraform du TP2 (hors périmètre du sujet).

---

## 7. Schéma du réseau créé par `network.tf`

```
rg-shopeasy-dev  (Resource Group — swedencentral)
└── vnet-shopeasy-dev  (10.20.0.0/16)
    ├── snet-web   10.20.1.0/24   ← VM web (compute.tf)
    └── snet-data  10.20.2.0/24   ← futur SQL (security.tf filtre l'accès)
```

Comparaison TP1 :

```
vnet-shopeasy-dev  (10.10.0.0/16)
├── snet-web    10.10.1.0/24
├── snet-data   10.10.2.0/24
└── snet-admin  10.10.3.0/24   ← uniquement TP1
```

---

## 8. Variables utilisées par `network.tf`

Déclarées dans [`variables.tf`](../../tp2/terraform/variables.tf) :

```hcl
variable "location" {
  default = "swedencentral"
}

variable "vnet_address_space" {
  default = "10.20.0.0/16"
}

variable "web_subnet_prefix" {
  default = "10.20.1.0/24"
}

variable "data_subnet_prefix" {
  default = "10.20.2.0/24"
}
```

### Pourquoi des variables et pas des valeurs en dur ?

| Avantage | Exemple |
|---|---|
| Réutiliser le code pour test/prod | Changer `environment = "test"` → noms différents |
| Adapter sans toucher la logique | Changer la plage IP si conflit |
| Documenter les choix | Le `description` explique chaque paramètre |

Équivalent bash : les variables en tête du script (`RG=`, `VNET=`, `LOCATION=`).

---

## 9. Locals utilisés par `network.tf`

Déclarés dans [`locals.tf`](../../tp2/terraform/locals.tf) :

```hcl
locals {
  prefix = "${var.project}-${var.environment}"   # → shopeasy-dev

  common_tags = {
    project     = "shopeasy"
    environment = "dev"
    owner       = "formation"
    managed_by  = "terraform"
    cost_center = "cloud-training"
  }
}
```

| Local | Utilisation dans `network.tf` |
|---|---|
| `local.prefix` | Noms `rg-shopeasy-dev`, `vnet-shopeasy-dev` |
| `local.common_tags` | Tags sur RG et VNet (FinOps, gouvernance) |

Équivalent bash :

```bash
--tags projet=shopeasy environnement=dev module=cloud proprietaire="${SUFFIX}"
```

---

## 10. Ordre de création au `terraform apply`

Terraform calcule automatiquement :

```
1. azurerm_resource_group.main
        ↓
2. azurerm_virtual_network.main
        ↓
3. azurerm_subnet.web  et  azurerm_subnet.data  (en parallèle possible)
```

C'est le même ordre logique que les ateliers 4–5 du bash, même si le bash crée web en même temps que le VNet.

---

## 11. Ce que vous verriez dans un `terraform plan` (premier déploiement)

```
+ azurerm_resource_group.main
+ azurerm_virtual_network.main
+ azurerm_subnet.web
+ azurerm_subnet.data

Plan: 4 to add, 0 to change, 0 to destroy.
```

Quatre `+` = quatre ressources **à créer**. Rien d'autre dans `network.tf`.

---

## 12. Questions de compréhension

Répondez sans regarder, puis vérifiez.

**Q1.** Que fait `azurerm_resource_group.main.name` dans le bloc VNet ?  
<details><summary>Réponse</summary>
Il récupère le nom du Resource Group (`rg-shopeasy-dev`) et crée une dépendance : le VNet est créé après le RG.
</details>

**Q2.** Pourquoi `10.20.0.0/16` et pas `10.10.0.0/16` ?  
<details><summary>Réponse</summary>
Même logique réseau, plage différente pour éviter les conflits si TP1 et TP2 coexistent, et pour montrer l'usage des variables plutôt que du code en dur.
</details>

**Q3.** Le subnet web est-il directement sur Internet ?  
<details><summary>Réponse</summary>
Non. C'est un réseau privé. L'exposition passe par des IP publiques et le Load Balancer (fichiers `compute.tf` et `loadbalancer.tf`).
</details>

---

## En résumé

| Bash TP1 | Terraform `network.tf` | Rôle |
|---|---|---|
| `az group create` | `azurerm_resource_group` | Conteneur du projet |
| `az network vnet create` | `azurerm_virtual_network` | Réseau privé |
| `--subnet-name snet-web` | `azurerm_subnet.web` | Zone des VM web |
| `az network vnet subnet create snet-data` | `azurerm_subnet.data` | Zone privée données |
| `snet-admin` | *(absent)* | Admin — TP1 seulement |

> **`network.tf` = la traduction texte des ateliers 4 et 5 du script bash.** Même intention, autre syntaxe, avec variables et dépendances automatiques.

**Retour :** [Index des cours](README.md) · [Index documentation](../README.md) · **Suite :** Cours 05 — `security.tf` (à venir)
