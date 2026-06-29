# TP4 — Analyse FinOps & revue de sécurité

> Environnement réel `rg-shopeasy-dev` (*Azure for Students*, `swedencentral`), analysé le 29/06/2026. Données issues de Cost Management, de la revue RBAC/NSG et d'Azure Advisor.

---

## 1. Analyse FinOps

### 1.1 Coûts constatés (mois en cours)

| Service | Coût (€) | Commentaire |
|---|---|---|
| Virtual Network | 0,9186 | Poste principal : IP publiques réservées (LB + 2 VM). |
| Storage | 0,2582 | Compte de stockage `shopeasydevdocsa0rnay` (LRS). |
| Virtual Machines | 0,0159 | Très faible : VM désallouées la plupart du temps. |
| Bandwidth / Azure Monitor / Load Balancer | ~0,0000 | Trafic et ingestion logs marginaux. |
| **Total mois en cours** | **1,1928** | Sous le budget de 50 €. |

> **Lecture FinOps.** Contrairement à un environnement classique où le compute domine, ici le coût résiduel vient du **réseau** (adresses IP publiques statiques facturées même VM éteintes). La désallocation des VM, héritée du TP3, est un levier déjà en place et efficace.

### 1.2 Constats et actions correctives (≥ 5)

| # | Constat | Risque financier | Priorité | Action corrective |
|---|---|---|---|---|
| 1 | 3 IP publiques réservées (LB + 2 VM) facturées en continu | Coût fixe même hors usage | Haute | Supprimer les IP publiques directes des VM (admin via Bastion/LB), ne garder que l'IP du LB. |
| 2 | VM `B2ts_v2` allumées pendant les tests, sous-utilisées (CPU < 10 %) | Dépense compute inutile | Haute | Désallouer hors période via `tp3/scripts/vm-power.sh deallocate` (automatisable). |
| 3 | Aucun budget actif avant ce TP | Dérive non détectée | Haute | **Fait** : budget `budget-shopeasy-dev` 50 €/mois, alertes 80 % réel / 100 % prévisionnel. |
| 4 | 12/14 ressources sans tag `Application` au départ | Coûts non ventilables | Moyenne | **Fait** : 16/16 ressources taguées (Application, Environment, Owner, CostCenter, Criticality). |
| 5 | Disques OS conservés sur VM désallouées | Coût stockage « oublié » | Moyenne | Inventaire régulier des disques (Advisor + `inventory.sh`), supprimer les disques orphelins. |
| 6 | Pas de revue régulière d'Advisor | Optimisations manquées | Basse | Revue mensuelle des recommandations Advisor (sizing, redondance). |

### 1.3 Politique de tags retenue

| Tag | Valeur ShopEasy | Utilité |
|---|---|---|
| Application | `ShopEasy` | Regrouper les coûts par application. |
| Environment | `dev` | Distinguer les environnements (dev/test/prod). |
| Owner | `equipe-cloud` | Identifier le responsable. |
| CostCenter | `DSI-Cloud` | Affecter les coûts. |
| Criticality | `high` / `medium` / `low` | Prioriser supervision et sécurité selon le type de ressource. |

> **Pérennisation.** Pour éviter la dérive, ces tags devraient être imposés à la création via **Azure Policy** (effet `deny` ou `modify`), plutôt qu'appliqués a posteriori.

---

## 2. Revue de sécurité

### 2.1 Constats

| Domaine | Constat réel | Évaluation |
|---|---|---|
| RBAC | 1 seul principal, rôle **Owner** sur toute la souscription | À renforcer (pas de moindre privilège) |
| NSG web | HTTP 80 ouvert à Internet ; SSH 22 restreint à `216.252.179.39/32` | Correct (SSH non exposé largement) |
| NSG data | SQL 1433 depuis le subnet web seulement + `Deny-All-Inbound` | Bon (subnet données isolé) |
| Stockage | Accès public blob désactivé, HTTPS only, TLS 1.2 | Conforme |
| Journalisation | Activity Log + Storage exportés vers `law-shopeasy-dev` | Mis en place au TP4 |
| Posture (Advisor) | Recommandations sécurité (Guest Configuration) et haute dispo | À traiter par priorité |

### 2.2 Matrice de risques (≥ 5)

| Risque | Impact | Probabilité | Criticité | Mesure corrective |
|---|---|---|---|---|
| Rôle Owner unique au niveau souscription | Action destructrice ou compromission totale | Moyenne | **Élevée** | Appliquer le moindre privilège : Reader/Contributor par périmètre, Owner réservé et limité. |
| HTTP 80 exposé sans HTTPS applicatif | Interception du trafic, downgrade | Moyenne | Moyenne | Terminer le TLS au niveau LB/Application Gateway, rediriger 80 → 443. |
| IP publiques directes sur les VM | Surface d'attaque (admin exposée) | Moyenne | Moyenne | Supprimer les IP publiques des VM, administrer via Azure Bastion. |
| Absence de Defender for Cloud / Guest Config | Vulnérabilités non détectées | Élevée | Moyenne | Activer Defender for Cloud (plan gratuit posture) + extension Guest Configuration. |
| Pas de Soft Delete sur le stockage | Perte/altération de données | Faible | Moyenne | Activer Soft Delete blob (recommandation Advisor). |
| Logs non conservés assez longtemps | Audit/forensics impossible | Faible | Faible | Rétention LAW 30 j → étendre à 90 j pour les catégories sécurité. |

### 2.3 Priorisation

- **Priorité haute :** moindre privilège RBAC, suppression des IP publiques d'admin.
- **Priorité moyenne :** TLS de bout en bout, Defender for Cloud, Soft Delete.
- **Priorité basse :** extension de rétention des logs, revue Advisor périodique.

---

## 3. Synthèse

L'environnement ShopEasy est **techniquement sain** au niveau réseau (subnet données isolé, SSH restreint, stockage privé) et **maîtrisé en coûts** (désallocation des VM, budget et tags en place). Les deux axes prioritaires avant production sont la **gouvernance des identités** (sortir du rôle Owner unique) et la **réduction de la surface d'exposition** (IP publiques d'administration, TLS applicatif).
