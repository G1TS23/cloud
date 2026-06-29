# Note de recommandations à la DSI — Exploitation de ShopEasy sur Azure

> Document de synthèse (atelier 9). Destinataire : Direction des Systèmes d'Information. Objet : état d'exploitation de l'environnement ShopEasy et plan d'amélioration avant mise en production.

## 1. Contexte et objectif

L'application **ShopEasy** a été migrée vers Microsoft Azure (groupe de ressources `rg-shopeasy-dev`, région `swedencentral`). Après les phases de conception (TP1), d'Infrastructure as Code (TP2) et d'administration (TP3), cette note évalue la capacité de l'environnement à être **exploité, surveillé, maîtrisé en coûts et sécurisé**, puis propose un plan d'action priorisé avant un éventuel passage en production.

## 2. État actuel de l'exploitation

L'environnement comprend 2 VM web Linux (Nginx, `Standard_B2ts_v2`), un Load Balancer, un réseau virtuel à deux subnets (web/data), deux NSG, un Storage Account et, désormais, un Log Analytics Workspace. Les VM sont **désallouées hors usage** (levier de coût appliqué dès le TP3).

| Domaine | État | Niveau |
|---|---|---|
| Observabilité | Workspace `law-shopeasy-dev` créé, Activity Log et Storage exportés | En place |
| Supervision VM | Métriques CPU/réseau lues ; CPU au repos < 10 % | En place |
| Alertes | 3 alertes (CPU, disponibilité, NSG) + Action Group email | En place |
| FinOps | Budget 50 €/mois, tags sur 16/16 ressources, coût 1,19 € MTD | En place |
| Sécurité réseau | SSH restreint, subnet données isolé, stockage privé | Satisfaisant |
| Gouvernance identités | Rôle Owner unique au niveau souscription | À renforcer |

## 3. Monitoring et alertes proposés

- **Observabilité centralisée** : Log Analytics Workspace `law-shopeasy-dev` (rétention 30 j) recevant l'Activity Log et les diagnostics du stockage.
- **Trois alertes actionnables** branchées sur l'Action Group `ag-shopeasy-ops` (email) : CPU > 70 % (sév. 2), VM indisponible (sév. 1), modification de règle NSG (audit).
- **Recommandation** : ajouter une sonde de disponibilité applicative (HTTP via le Load Balancer) et activer VM Insights pour la supervision mémoire et les logs invité.

## 4. Analyse FinOps

Le coût mensuel constaté est faible (**1,19 €**), bien en deçà du budget de 50 €, grâce à la désallocation des VM. Le poste résiduel principal est le **réseau** (IP publiques réservées). Actions retenues : suppression des IP publiques d'administration, automatisation de l'extinction des VM, et imposition des tags par Azure Policy. Détail dans [`03_analyse_finops_securite.md`](03_analyse_finops_securite.md).

## 5. Analyse sécurité

Les fondamentaux réseau sont sains (SSH restreint à une IP, subnet données en `Deny-All`, stockage privé en TLS 1.2). Le principal point faible est la **gouvernance des identités** : un unique rôle Owner sur toute la souscription, contraire au moindre privilège. Azure Advisor signale par ailleurs des améliorations de posture (Guest Configuration, Soft Delete, haute disponibilité). Matrice complète dans [`03_analyse_finops_securite.md`](03_analyse_finops_securite.md).

## 6. Risques résiduels

- Rôle Owner unique : impact élevé en cas de compromission du compte.
- Surface d'exposition : IP publiques directes sur les VM, HTTP non chiffré côté applicatif.
- Absence de Defender for Cloud : vulnérabilités de posture non suivies en continu.
- Base de données absente de l'environnement actuel : la supervision SQL reste à intégrer avant production.

## 7. Plan d'action priorisé

| Action | Priorité | Responsable | Gain attendu |
|---|---|---|---|
| Activer les alertes critiques (fait) et y associer des runbooks | Haute | Équipe Cloud | Détection et traitement rapides des incidents |
| Réduire les droits RBAC (sortir du rôle Owner unique) | Haute | Sécurité / DSI | Réduction du risque de compromission |
| Supprimer les IP publiques d'admin, passer par Bastion | Haute | Sécurité / Ops | Réduction de la surface d'attaque |
| Imposer les tags via Azure Policy | Moyenne | Équipe projet | Pilotage durable des coûts |
| Maintenir budget et revue Cost Management mensuelle (fait) | Moyenne | FinOps | Maîtrise des dépenses |
| Activer Defender for Cloud + Soft Delete | Moyenne | Sécurité | Amélioration continue de la posture |
| Formaliser un dashboard d'exploitation partagé | Moyenne | Ops | Visibilité DSI |

## 8. Conclusion

L'environnement ShopEasy dispose d'une **base technique exploitable** : il est désormais surveillé (workspace, métriques, alertes actionnables), maîtrisé en coûts (budget, tags, désallocation) et correctement isolé au niveau réseau. Il doit toutefois être **renforcé avant toute mise en production**, en priorité sur la gouvernance des identités (moindre privilège) et la réduction de la surface d'exposition (IP d'administration, TLS applicatif). La mise en œuvre du plan d'action ci-dessus permet de réduire le risque opérationnel, d'améliorer la visibilité de la DSI et de pérenniser la maîtrise des coûts cloud.
