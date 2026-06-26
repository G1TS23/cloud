# Cours 01 — Contexte ShopEasy : TP1 et TP2

> **Prérequis :** aucun.  
> **Objectif :** arriver sur le projet sans connaître les attentes ni la solution — comprendre *pourquoi* on fait tout ça et *ce qu'on a concrètement réalisé* dans chaque TP.  
> **Suite :** [Cours 02 — Terraform sans le code](02_terraform_comprendre_sans_le_code.md)

---

## 1. Le contexte métier

**ShopEasy** est une application web de **gestion de commandes** (fictive, cas fil rouge du cours).

Aujourd'hui, en entreprise, tout tourne sur **un seul serveur physique** :
- le site web,
- la base de données,
- les documents (factures, etc.).

### Problèmes de l'existant

| Domaine | Problème |
|---|---|
| Disponibilité | Un seul serveur = si il tombe, tout s'arrête |
| Sécurité | Compte admin partagé, pas de vrai pare-feu réseau |
| Performance | Web + base + fichiers sur la même machine |
| Exploitation | Pas de supervision, pas d'alertes |
| Sauvegarde | Manuelle, irrégulière |

**Mission du module :** concevoir puis déployer une **architecture Azure** plus robuste pour héberger ShopEasy.

> Ce n'est **pas** un cours de développement d'application. On ne code pas ShopEasy en React ou PHP. On construit **l'infrastructure** autour (réseau, serveurs, stockage, sécurité).

---

## 2. Vue d'ensemble des deux TPs

```
TP1  →  « Quoi déployer ? Pourquoi ? Comment le faire à la main ? »
TP2  →  « Comment décrire tout ça en code pour ne plus le refaire à la main ? »
```

Le TP2 **n'optimise pas** l'application ShopEasy elle-même. Il **industrialise** la façon de créer l'infrastructure : reproductible, versionnée, contrôlable.

Le bloc s'appelle *« Optimisation du SI par le Cloud »* : l'optimisation, c'est passer d'un serveur unique fragile à une archi cloud + automatisation (IaC).

---

## 3. TP1 — Ce qu'on faisait concrètement

### Objectif

Répondre à : *« Si ShopEasy part sur Azure, à quoi ça ressemble et comment on le monte ? »*

C'est un TP d'**architecture cloud** : réflexion + déploiement **manuel**.

### Phase A — Réflexion (ateliers 1–3)

1. **Analyser** les risques de l'ancien serveur (panne, sécurité, perf…).
2. **Choisir** les services Azure adaptés.
3. **Dessiner** l'architecture cible (schémas dans [`tp1/architecture/`](../../tp1/architecture/)).

| Besoin | Service Azure choisi | Modèle |
|---|---|---|
| Héberger le site | 2 VM Linux + Nginx | IaaS |
| Éviter qu'une VM tombe tout | Load Balancer | IaaS |
| Base de données | Azure SQL Database | PaaS |
| Fichiers clients | Storage Account (Blob) | PaaS |
| Isoler les couches | VNet + subnets | IaaS |
| Filtrer le réseau | Network Security Groups | IaaS |
| Droits d'accès | Entra ID + RBAC | Gouvernance |
| Surveillance | Azure Monitor | PaaS |

### Phase B — Déploiement manuel (ateliers 4–11)

On **crée vraiment** l'infra dans Azure via le portail et/ou le script bash [`scripts/deploy_shopeasy.sh`](../../scripts/deploy_shopeasy.sh).

**Ordre de création du script bash :**

```
1. Resource Group          → dossier Azure "rg-shopeasy-dev"
2. Réseau                  → VNet 10.10.0.0/16 + 3 subnets (web, data, admin)
3. Pare-feux (NSG)         → HTTP/HTTPS/SSH sur le web, SQL depuis le web seulement
4. 2 VM Ubuntu             → Nginx installé auto, pages "ShopEasy - VM Web 01/02"
5. Load Balancer           → 1 IP publique qui répartit le trafic sur les 2 VM
6. Storage Account         → conteneurs factures, clients, archives
7. Azure SQL               → base managée pour les commandes
8. Alerte Monitor          → alerte si CPU > 80%
```

**Résultat visible :** ouvrir `http://IP_DU_LOAD_BALANCER` → page ShopEasy.

### Phase C — Livrables TP1

- Analyse des risques et choix de services
- Schéma d'architecture
- Captures du portail Azure
- Note à la DSI
- Quiz

**En résumé TP1 :** on apprend **le cloud Azure** en **construisant une vraie infra à la main**.

---

## 4. TP2 — Ce qu'on fait concrètement

### Le problème posé après le TP1

> *« L'architecture marche. Mais si demain on veut un environnement **test** identique au **dev** ? Si on veut tout **supprimer** vendredi soir ? Si 3 personnes modifient l'infra en cliquant dans le portail ? »*

Avec le TP1 seul : on **reclique** tout ou on relance le script bash. Risque d'oubli, d'écart, pas de traçabilité fine.

### Objectif du TP2

Transformer l'architecture en **fichiers texte** (Terraform) pour pouvoir :

- recréer la même infra en quelques minutes ;
- versionner dans Git ;
- prévisualiser les changements (`plan`) ;
- tout détruire proprement (`destroy`) → pas de frais le week-end.

### Ce qu'on construit — comparaison TP1 / TP2

| Composant | TP1 (manuel) | TP2 (Terraform) |
|---|---|---|
| Resource Group | ✅ | ✅ |
| VNet + subnets | 3 subnets (web, data, admin) | 2 subnets (web, data) |
| NSG | ✅ | ✅ |
| 2 VM + Nginx | ✅ | ✅ |
| Load Balancer | ✅ | ✅ |
| Storage Account | 3 conteneurs | 1 conteneur `documents` |
| Azure SQL | ✅ | ❌ (pas dans le code Terraform) |
| Azure Monitor | ✅ | ❌ |
| Subnet admin | ✅ | ❌ |

Le TP2 est une **version simplifiée** de l'archi TP1, focalisée sur **l'apprentissage de Terraform**.

### Ce qu'on fait au TP2 (concrètement)

1. **Écrire** l'infra en fichiers `.tf` dans [`tp2/terraform/`](../../tp2/terraform/).
2. **Lancer** le cycle Terraform : `init → fmt → validate → plan → apply → output → destroy`.
3. **Vérifier** dans le navigateur que `http://IP_LB` affiche ShopEasy.
4. **Documenter** : captures, quiz, analyse FinOps.
5. **`destroy`** en fin de séance.

---

## 5. Schéma : ce que voit un utilisateur

Les deux TPs visent le même **flux utilisateur** :

```
Utilisateur Internet
        │
        │  http://IP_PUBLIQUE
        ▼
   Load Balancer  ←── seule vraie entrée "officielle"
        │
   ┌────┴────┐
   ▼         ▼
 VM web 1   VM web 2    (Nginx affiche "ShopEasy")
   │         │
   └────┬────┘
        │  (futur : SQL port 1433)
        ▼
   subnet data (privé)
        │
   Storage (documents)
```

---

## 6. Analogie : la maison ShopEasy

| | TP1 | TP2 |
|---|---|---|
| **Rôle** | Architecte + artisan sur chantier | Architecte qui écrit le plan détaillé |
| **Action** | Pose briques, câbles, portes une par une | Donne le plan à un robot (Terraform) |
| **Résultat** | Maison habitable | Même type de maison, mais reproductible |
| **Avantage** | On comprend chaque pièce | On peut reconstruire 10 fois identique |

---

## 7. Ce que Terraform change (sans parler du code)

| Situation | TP1 (manuel) | TP2 (Terraform) |
|---|---|---|
| Recréer l'env de dev | Recliquer 2 h dans le portail | `terraform apply` |
| Savoir ce qui va changer | On ne sait qu'après | `terraform plan` montre tout avant |
| Qui a modifié quoi | Flou (portail) | Historique Git |
| Supprimer tout | Script `cleanup` ou manuel | `terraform destroy` |
| Oublier une règle NSG | Environnements différents | Même code = même infra |

---

## 8. Les outils, par TP

### TP1
- Portail Azure (clics)
- Azure CLI (`az`) — script bash
- Diagrammes (draw.io, Mermaid)

### TP2
- **Terraform** — décrit l'infra en `.tf`
- **Azure CLI** — seulement pour `az login`
- **Git** — versionner le code (pas le state)
- **`azure-account.sh`** — éviter le mauvais compte Azure

---

## 9. Attentes (sans spoiler la solution)

### TP1 — on vous demande de :
1. Analyser pourquoi l'existant est risqué.
2. Choisir et justifier les services Azure.
3. Dessiner une architecture cible.
4. **Déployer** cette architecture manuellement.
5. Prouver que ça marche (captures, tests HTTP).
6. Rédiger des livrables (note DSI, quiz).

### TP2 — on vous demande de :
1. **Coder** la même logique d'infra (en plus simple).
2. Maîtriser le **workflow Terraform**.
3. Comprendre variables, state, drift, sécurité.
4. Prouver l'exécution (captures).
5. **`destroy`** en fin de séance.
6. Rédiger note technique + quiz + analyse FinOps.

---

## En résumé

> **TP1** : on apprend **quelle infrastructure Azure** ShopEasy a besoin, et on la **monte à la main**.  
> **TP2** : on prend cette même logique et on l'**écrit en code** pour la recréer, la contrôler et la détruire proprement.

**Suite :** [Cours 02 — Terraform : comprendre sans le code](02_terraform_comprendre_sans_le_code.md) · [Index documentation](../README.md)
