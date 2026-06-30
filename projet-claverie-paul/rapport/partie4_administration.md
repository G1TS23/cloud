# Partie 4 — Administration, exploitation et automatisation

> Inventaire, gouvernance par tags et automatisation d'une tâche d'exploitation, appuyés sur l'infrastructure **réellement déployée**.
> **Barème : 2 pts** — inventaire, tags, script ou pseudo-script utile, logique d'exploitation.

---

## Question 12 — Inventaire d'exploitation

Inventaire des ressources réellement déployées dans `rg-novaretail-prod` (région `swedencentral`). Tous les éléments portent les tags de gouvernance (cf. Q13) : `environment=prod`, `application=novaretail`, `owner=paul.claverie`, `cost-center=efrei-mastere`, `criticality=high`, `review-date=2026-12-31`, `managed-by=terraform`.

| Nom | Type | Resource Group | Région | Rôle dans l'architecture |
|---|---|---|---|---|
| `vnet-nr-novaretail-prod` | Virtual Network | rg-novaretail-prod | swedencentral | Réseau privé isolant l'ensemble des ressources |
| `snet-web` | Subnet | rg-novaretail-prod | swedencentral | Sous-réseau de la couche web (10.10.1.0/24) |
| `snet-data` | Subnet | rg-novaretail-prod | swedencentral | Sous-réseau de la couche données (10.10.2.0/24) |
| `nsg-web` | Network Security Group | rg-novaretail-prod | swedencentral | Filtrage : HTTP/HTTPS entrant, SSH restreint |
| `nsg-data` | Network Security Group | rg-novaretail-prod | swedencentral | Filtrage : MySQL 3306 depuis le web uniquement |
| `vm-web-01` | Machine virtuelle | rg-novaretail-prod | swedencentral | Serveur web Apache (nœud 1), IP privée 10.10.1.4 |
| `vm-web-02` | Machine virtuelle | rg-novaretail-prod | swedencentral | Serveur web Apache (nœud 2), IP privée 10.10.1.5 |
| `nic-web-01` / `nic-web-02` | Interface réseau | rg-novaretail-prod | swedencentral | Cartes réseau des VM (sans IP publique) |
| `lb-nr-novaretail-prod` | Load Balancer (Standard) | rg-novaretail-prod | swedencentral | Répartition de charge + point d'entrée HTTP |
| `pip-nr-novaretail-prod-lb` | Adresse IP publique | rg-novaretail-prod | swedencentral | IP publique du point d'entrée (20.91.200.239) |
| `stnovaretailja69ku` | Storage Account | rg-novaretail-prod | swedencentral | Stockage privé des fichiers clients (Blob) |
| `log-nr-novaretail-prod` | Log Analytics Workspace | rg-novaretail-prod | swedencentral | Supervision et journalisation centralisée |
| `mysql-nr-novaretail-prod` | Azure DB for MySQL Flexible | rg-novaretail-prod | swedencentral | Base de données managée (remplace MySQL/VM) |

> Inventaire généré via `az resource list` — source brute dans [`screenshots/cli-evidence/01_resource_group.txt`](../screenshots/cli-evidence/01_resource_group.txt).

---

## Question 13 — Tags et gouvernance

### Stratégie de tags proposée

| Tag | Valeur (exemple) | Finalité |
|---|---|---|
| `environment` | `prod` / `dev` | Distinguer les environnements, filtrer et appliquer des politiques par cycle de vie. |
| `application` | `novaretail` | Regrouper toutes les ressources d'une même application pour l'exploitation et la refacturation. |
| `owner` | `paul.claverie` | Identifier le responsable de la ressource (contact en cas d'incident, imputabilité). |
| `cost-center` | `efrei-mastere` | Rattacher la dépense à un centre de coût pour le FinOps et la refacturation interne. |
| `criticality` | `high` / `medium` / `low` | Prioriser la supervision, les sauvegardes et la réponse aux incidents. |
| `review-date` | `2026-12-31` | Planifier la revue / le nettoyage des ressources (évite les ressources orphelines). |

Tag complémentaire technique : `managed-by=terraform` (trace l'origine IaC, évite les modifications manuelles).

### Pourquoi les tags sont importants (administration + FinOps)

- **Administration** : ils permettent de **filtrer et regrouper** les ressources (par application, environnement, criticité), d'automatiser des actions ciblées (ex. arrêter toutes les VM `environment=dev` la nuit) et d'identifier rapidement un **responsable** lors d'un incident.
- **FinOps** : ils sont la **clé de la ventilation des coûts**. Sans tags, Azure Cost Management ne peut pas répartir la facture par application ou centre de coût. Les tags `cost-center`, `application` et `environment` rendent possibles les rapports de coût, les budgets ciblés et la détection des dépenses anormales.
- **Gouvernance** : `review-date` et `owner` luttent contre les ressources orphelines (gaspillage), `criticality` oriente les politiques de sauvegarde et d'alerte.

---

## Question 14 — Automatisation d'une tâche récurrente

Script [`scripts/audit_tags.sh`](../scripts/audit_tags.sh) — **détection des ressources ne respectant pas la stratégie de tags obligatoires**.

| Élément | Description |
|---|---|
| **Objectif** | Lister les ressources d'un Resource Group qui ne portent pas tous les tags obligatoires (`environment`, `application`, `owner`, `cost-center`, `criticality`, `review-date`), pour garantir la conformité de gouvernance et la fiabilité du suivi FinOps. |
| **Entrées** | Nom du Resource Group en argument (`$1`, défaut `rg-novaretail-prod`) ; liste des tags obligatoires définie dans le script ; session `az login` active. |
| **Sortie** | Affichage console des non-conformités (tag manquant → ressource), un fichier CSV horodaté `audit_tags_<rg>_<date>.csv`, et un **code de sortie** (0 = conforme, 3 = non conforme) exploitable en CI/CD. |
| **Logique principale** | Pour chaque tag obligatoire, le script interroge Azure via une requête **JMESPath** `[?tags."<tag>"==null].name` qui renvoie les ressources où le tag est absent, puis agrège, affiche et enregistre les non-conformités. |
| **Limites** | Audite un seul Resource Group à la fois ; en lecture seule (ne corrige pas automatiquement, par prudence) ; certaines ressources (sous-réseaux, disques) n'exposent pas toujours de tags ; dépend d'Azure CLI (aucune dépendance externe comme `jq`). |

### Exécution réelle (résultat)

```text
Audit des tags obligatoires sur le Resource Group : rg-novaretail-prod
Tags requis : environment application owner cost-center criticality review-date
----------------------------------------------------------------------
----------------------------------------------------------------------
Ressources dans le groupe : 14
Occurrences non conformes (tag x ressource) : 0
RÉSULTAT : toutes les ressources sont conformes.
```

L'audit confirme que **les 14 ressources déployées sont conformes** à la stratégie de tags (les tags ayant été appliqués dès l'IaC via Terraform). Sortie archivée dans [`screenshots/cli-evidence/10_audit_tags.txt`](../screenshots/cli-evidence/10_audit_tags.txt).

> Un second script, [`scripts/azure-account.sh`](../scripts/azure-account.sh), automatise la vérification du compte/souscription Azure avant tout déploiement (garde-fou d'exploitation).
