# TP2 Terraform — Mise en autonomie : Option A — Subnet privé pour les données

> Atelier 19, option A du sujet. Extension de l'infrastructure ShopEasy : ajout d'un subnet privé destiné à accueillir une future base de données, sans aucune exposition publique.

---

## 1. Modification choisie

Ajouter au VNet un **subnet privé `snet-data`** (`10.20.2.0/24`) cloisonné par un **NSG dédié `nsg-shopeasy-dev-data`** :

- autorise **uniquement** le port **1433** (SQL Server) **depuis le subnet web** (`10.20.1.0/24`) ;
- **refuse tout autre trafic entrant** (règle `Deny-All-Inbound` priorité 4000) ;
- n'attache **aucune IP publique** : le subnet reste injoignable depuis Internet.

Ce choix prolonge naturellement l'architecture TP1 (qui prévoyait déjà une couche data isolée) et illustre la **segmentation réseau** (défense en profondeur) sans coût supplémentaire ni service complexe à déployer.

---

## 2. Fichiers impactés

| Fichier | Changement |
|---|---|
| [`network.tf`](../terraform/network.tf) | Ajout de la ressource `azurerm_subnet.data` (`snet-data`, `10.20.2.0/24`) |
| [`security.tf`](../terraform/security.tf) | Ajout de `azurerm_network_security_group.data` (Allow-SQL-From-Web + Deny-All-Inbound) et de `azurerm_subnet_network_security_group_association.data` |
| [`variables.tf`](../terraform/variables.tf) | Ajout de la variable `data_subnet_prefix` (défaut `10.20.2.0/24`) |

Extrait clé (`security.tf`) :

```hcl
resource "azurerm_network_security_group" "data" {
  name = "nsg-${local.prefix}-data"
  # ...
  security_rule {
    name                   = "Allow-SQL-From-Web"
    priority               = 100
    destination_port_range = "1433"
    source_address_prefix  = var.web_subnet_prefix
    # ...
  }
  security_rule {
    name                   = "Deny-All-Inbound"
    priority               = 4000
    access                 = "Deny"
    # ...
  }
}
```

---

## 3. Risques associés et points de vigilance

| Risque | Description | Atténuation |
|---|---|---|
| **Faux sentiment de sécurité** | Le subnet est isolé, mais une base réellement déployée nécessiterait aussi un private endpoint et un chiffrement | Compléter avec Azure SQL + private endpoint + TLS lors de l'ajout réel de la base |
| **Règle trop large** | Autoriser tout le subnet web vers 1433 reste plus permissif qu'un private endpoint nominatif | Restreindre ultérieurement aux NIC précises ou via Application Security Groups |
| **Chevauchement d'adressage** | `10.20.2.0/24` doit rester dans `10.20.0.0/16` et ne pas chevaucher `snet-web` | Préfixes gérés par variables, espaces disjoints vérifiés |
| **Subnet vide facturé ?** | Un subnet seul n'est pas facturé, mais les futures ressources le seront | Documenter ; `destroy` en fin de séance |
| **Évolution vers PaaS** | Pour Azure SQL managé, prévoir `service delegation` / `private endpoint` plutôt qu'une VM data | Anticipé dans la roadmap (voir note technique) |

---

## 4. Variante envisagée — Option D (Storage lifecycle)

À titre complémentaire, une règle de cycle de vie limiterait le surcoût du versioning Blob (atelier 8). Elle pourrait être ajoutée dans `storage.tf` :

```hcl
resource "azurerm_storage_management_policy" "docs" {
  storage_account_id = azurerm_storage_account.docs.id
  rule {
    name    = "expire-old-versions"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      version {
        delete_after_days_since_creation = 90
      }
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = 30
      }
    }
  }
}
```

> Option A retenue comme extension principale ; la variante D est documentée comme évolution FinOps possible.
