# Épreuve finale pratique — Cloud Azure

**Architecture, diagnostic, Terraform, administration, monitoring, FinOps, sécurité et traçabilité**

| Élément | Détail |
|---|---|
| Durée totale | 5 heures |
| Type | Épreuve individuelle — Niveau Mastère |
| Module | Panorama du cloud et déploiement Azure |
| Bloc visé | Optimisation du SI par l'apport du Cloud Computing |
| Compétences mobilisées | Choix de services cloud, automatisation, administration, monitoring, FinOps, sécurité, traçabilité blockchain, recommandations SI |
| Rendu | Dossier numérique contenant les livrables demandés |
| Barème | 20 points |

> _Conversion fidèle du sujet officiel `EPREUVE_CLOUD_AZURE.pdf` (14 pages) au format Markdown. Le contenu, les tableaux et le barème sont reproduits à l'identique._

---

## 1. Consignes générales

Cette épreuve évalue votre capacité à analyser un besoin d'entreprise, proposer une architecture cloud Azure, déployer ou décrire un déploiement reproductible, sécuriser l'environnement, superviser les ressources, estimer les coûts et formuler des recommandations pour une DSI.

### 1.1 Règles de rendu

Le rendu doit être déposé sous forme d'un dossier compressé contenant au minimum :

- un rapport final au format PDF ;
- le schéma d'architecture exporté en PDF ou PNG ;
- les fichiers Terraform produits ou complétés ;
- le diagnostic de l'architecture défectueuse et les corrections proposées ;
- les captures de validation demandées ;
- les réponses aux questions théoriques ;
- la note de recommandations DSI.

### 1.2 Ce qui est attendu

Les réponses doivent être justifiées. Une simple liste de services ne suffit pas : il faut expliquer les choix techniques selon les critères de **coût, sécurité, performance, disponibilité et exploitabilité**.

La notation privilégie la cohérence globale, la qualité des justifications, la traçabilité des choix et la capacité à produire des livrables exploitables. Les captures doivent être lisibles et les noms de ressources doivent être cohérents.

---

## 2. Cas d'entreprise

La société **NovaRetail** exploite une application web de gestion de commandes pour ses équipes commerciales. L'application est aujourd'hui hébergée sur un serveur unique dans une salle informatique interne.

### 2.1 Situation actuelle

- un serveur Linux unique ;
- application web Apache/PHP ;
- base de données MySQL locale ;
- fichiers clients stockés sur le même serveur ;
- sauvegarde manuelle hebdomadaire ;
- pas de tableau de bord de supervision ;
- accès administrateur partagé entre plusieurs personnes ;
- aucune estimation précise des coûts d'exploitation.

### 2.2 Objectif de migration

La direction souhaite migrer cette application vers Azure afin de :

- améliorer la disponibilité de l'application ;
- séparer les couches réseau, applicative, données et stockage ;
- automatiser la création de l'infrastructure ;
- mettre en place une première supervision ;
- renforcer la sécurité des accès ;
- mieux maîtriser les coûts cloud ;
- disposer d'une note de recommandations claire pour la DSI.

---

## 3. Partie 1 — Analyse de l'existant et architecture cible

### 3.1 Question 1 — Analyse de l'existant

À partir du contexte, identifiez les principaux risques de l'architecture actuelle. Complétez le tableau suivant dans votre rapport.

| Domaine | Risque identifié | Impact possible sur le SI |
|---|---|---|
| Disponibilité | | |
| Sécurité | | |
| Performance | | |
| Exploitation | | |
| Coûts | | |
| Sauvegarde | | |

### 3.2 Question 2 — Choix des services Azure

Proposez les services Azure adaptés aux besoins ci-dessous et justifiez vos choix.

| Besoin | Service Azure proposé | Justification |
|---|---|---|
| Hébergement applicatif | | |
| Réseau isolé | | |
| Filtrage réseau | | |
| Stockage de documents | | |
| Base de données managée | | |
| Supervision | | |
| Gestion des coûts | | |
| Gestion des droits | | |
| Journalisation / audit | | |

### 3.3 Question 3 — Architecture cible

Produisez un schéma d'architecture cible comprenant au minimum :

- un Resource Group ;
- un Virtual Network ;
- deux subnets ;
- des Network Security Groups ;
- deux machines virtuelles Linux ;
- un Load Balancer ou une Application Gateway ;
- un Storage Account ;
- une base de données managée ;
- Azure Monitor et Log Analytics ;
- les flux entrants, sortants et internes.

> **Livrables de la partie 1 :** tableau d'analyse de l'existant, tableau de choix des services, schéma d'architecture cible, justification courte des principaux choix.

---

## 4. Partie 2 — Diagnostic d'une architecture défectueuse

Dans cette partie, vous devez auditer une architecture volontairement imparfaite. L'objectif est de vérifier votre capacité à repérer des risques, à les prioriser et à proposer des corrections réalistes. Les réponses doivent être précises et contextualisées.

### 4.1 Architecture proposée par un prestataire externe

Un prestataire a proposé l'architecture suivante pour NovaRetail. La DSI vous demande de l'analyser avant toute mise en production.

- un seul Resource Group nommé `rg-prod-novaretail` contenant toutes les ressources DEV et PROD ;
- un seul Virtual Network `10.0.0.0/24` avec un seul subnet ;
- deux machines virtuelles Linux avec adresse IP publique ;
- le port SSH est ouvert depuis `0.0.0.0/0` ;
- les deux VM web ne sont pas placées derrière un Load Balancer ;
- la base MySQL est installée sur une VM dans le même subnet que les serveurs web ;
- le port MySQL `3306` est accessible depuis Internet ;
- les mots de passe administrateurs sont stockés dans un fichier `terraform.tfvars` versionné dans le dépôt Git ;
- le state Terraform est local et stocké dans le poste d'un administrateur ;
- le Storage Account autorise l'accès public aux blobs ;
- le versioning et le soft delete ne sont pas activés sur le Storage Account ;
- aucune sauvegarde n'est configurée ;
- aucun Log Analytics Workspace n'est rattaché aux ressources ;
- aucune alerte n'est définie ;
- aucune stratégie de tags n'est appliquée ;
- aucun budget Azure n'est configuré ;
- plusieurs utilisateurs humains disposent du rôle Owner sur la souscription ;
- aucune séparation claire n'existe entre l'environnement de test et l'environnement de production.

### 4.2 Question 4 — Identification des anomalies

Identifiez au moins **12 anomalies** dans l'architecture ci-dessus. Pour chaque anomalie, indiquez le domaine concerné : sécurité, disponibilité, exploitation, FinOps, gouvernance ou Infrastructure as Code.

| No | Anomalie identifiée | Domaine | Risque principal |
|---|---|---|---|
| 1 | | | |
| 2 | | | |
| 3 | | | |
| 4 | | | |
| 5 | | | |
| 6 | | | |
| 7 | | | |
| 8 | | | |
| 9 | | | |
| 10 | | | |
| 11 | | | |
| 12 | | | |

### 4.3 Question 5 — Priorisation des risques

Parmi les anomalies identifiées, choisissez les **5 risques les plus critiques**. Pour chacun, justifiez la criticité et proposez une mesure corrective concrète.

| Risque critique | Niveau | Justification | Correction prioritaire |
|---|---|---|---|

### 4.4 Question 6 — Proposition d'architecture corrigée

Proposez une version corrigée de l'architecture. Votre proposition doit inclure au minimum :

- séparation des environnements DEV et PROD ;
- segmentation réseau avec subnets distincts ;
- filtrage réseau adapté avec NSG ;
- suppression des expositions inutiles à Internet ;
- remplacement de la base MySQL sur VM par un service managé lorsque c'est pertinent ;
- gestion sécurisée des secrets ;
- stockage Terraform state distant et protégé ;
- supervision, alertes, sauvegardes et tags ;
- mesures de contrôle des coûts.

Vous pouvez fournir un schéma corrigé ou compléter votre schéma d'architecture global.

### 4.5 Question 7 — Plan de vérification

Expliquez comment vous vérifieriez que les corrections proposées sont bien appliquées. Votre réponse doit citer au moins :

- une vérification réseau ;
- une vérification sécurité / RBAC ;
- une vérification Terraform ;
- une vérification monitoring ;
- une vérification FinOps.

> **Livrables de la partie 2 :** tableau des anomalies, matrice de priorisation, architecture corrigée ou schéma annoté, plan de vérification.

---

## 5. Partie 3 — Déploiement et Infrastructure as Code

### 5.1 Question 8 — Organisation du projet Terraform

Vous devez proposer une structure de projet Terraform permettant de créer l'infrastructure minimale. Votre projet doit contenir au moins les fichiers suivants :

- `main.tf` ;
- `variables.tf` ;
- `outputs.tf` ;
- `terraform.tfvars` ;
- un fichier `README.md` expliquant comment utiliser le projet.

Expliquez le rôle de chaque fichier dans votre rapport.

### 5.2 Question 9 — Ressources à créer ou à décrire

À l'aide de Terraform, créez ou décrivez les ressources suivantes :

- Resource Group ;
- Virtual Network ;
- au moins deux subnets ;
- Network Security Group avec règles HTTP et SSH contrôlées ;
- deux machines virtuelles Linux ou une définition équivalente documentée ;
- Load Balancer ou Application Gateway ;
- Storage Account ;
- Log Analytics Workspace ou ressource de supervision équivalente.

### 5.3 Question 10 — Variables et outputs

Votre code doit utiliser des variables pour les éléments suivants :

- nom du projet ;
- région Azure ;
- environnement ;
- préfixe de nommage ;
- plage d'adressage du VNet ;
- taille des machines virtuelles.

Prévoyez au moins trois outputs utiles : par exemple nom du Resource Group, adresse publique du point d'entrée, nom du Storage Account.

### 5.4 Question 11 — Validation du déploiement

Vous devez fournir des preuves de validation :

- capture du Resource Group ;
- capture du VNet et des subnets ;
- capture des NSG ;
- capture des machines virtuelles ou de l'équivalent déployé ;
- capture du point d'entrée HTTP ;
- extrait lisible du plan Terraform ou du résultat de déploiement.

Si le déploiement complet n'est pas possible dans l'environnement fourni, vous devez produire le code Terraform cohérent, expliquer les limites rencontrées et fournir les validations partielles disponibles.

> **Livrables de la partie 3 :** dossier Terraform, captures de validation, explication de la structure du projet, justification des variables et outputs.

---

## 6. Partie 4 — Administration, exploitation et automatisation

### 6.1 Question 12 — Inventaire d'exploitation

Produisez un inventaire des ressources déployées ou prévues. L'inventaire doit contenir :

- nom de la ressource ;
- type ;
- groupe de ressources ;
- région ;
- tags ;
- rôle dans l'architecture.

| Nom | Type | Resource Group | Région | Rôle |
|---|---|---|---|---|

### 6.2 Question 13 — Tags et gouvernance

Proposez une stratégie de tags pour faciliter l'exploitation et le pilotage des coûts. Votre proposition doit inclure au minimum :

- environnement ;
- application ;
- propriétaire ;
- centre de coût ;
- criticité ;
- date de revue.

Expliquez pourquoi les tags sont importants pour l'administration et le FinOps.

### 6.3 Question 14 — Automatisation d'une tâche récurrente

Proposez un script ou un pseudo-script d'exploitation permettant de réaliser une tâche utile, par exemple :

- lister les ressources non taguées ;
- vérifier l'état des machines virtuelles ;
- exporter un inventaire dans un fichier ;
- identifier les ressources potentiellement inutilisées ;
- vérifier la présence d'un tag obligatoire.

Votre réponse doit contenir :

- l'objectif du script ;
- les entrées attendues ;
- la sortie attendue ;
- la logique principale ;
- les limites du script.

> **Livrables de la partie 4 :** inventaire, stratégie de tags, script ou pseudo-script d'exploitation documenté.

---

## 7. Partie 5 — Monitoring, FinOps et sécurité

### 7.1 Question 15 — Monitoring et alertes

Proposez un dispositif de supervision pour l'application NovaRetail. Votre proposition doit inclure :

- au moins quatre métriques à surveiller ;
- au moins deux alertes ;
- un tableau de bord d'exploitation ;
- l'utilisation de logs ou d'un workspace d'analyse ;
- les personnes ou équipes concernées par les alertes.

| Élément surveillé | Métrique / log | Seuil | Action attendue |
|---|---|---|---|
| Disponibilité applicative | | | |
| CPU VM | | | |
| Base de données | | | |
| Stockage | | | |
| Coût | | | |

### 7.2 Question 16 — Analyse FinOps

À partir de l'architecture cible, proposez une première analyse FinOps. Votre réponse doit inclure :

- les principaux postes de coût ;
- les risques de dépassement budgétaire ;
- les tags nécessaires au suivi ;
- un budget ou une alerte de coût ;
- trois pistes d'optimisation à court terme ;
- deux pistes d'optimisation à moyen terme.

### 7.3 Question 17 — Revue sécurité

Réalisez une revue de sécurité de l'architecture proposée. Votre analyse doit couvrir au minimum : RBAC, accès administrateur, exposition réseau, NSG, stockage, base de données, journaux d'audit, chiffrement, sauvegarde, gestion des secrets.

| Risque | Description | Criticité | Mesure corrective |
|---|---|---|---|
| Accès trop ouverts | | | |
| Absence de logs | | | |
| Droits excessifs | | | |
| Données mal protégées | | | |
| Sauvegarde insuffisante | | | |

### 7.4 Question 18 — Recommandations DSI

Rédigez une note de recommandations destinée à la DSI. Cette note doit être concise, structurée et directement exploitable. Elle doit contenir :

- le résumé de l'architecture retenue ;
- les bénéfices attendus ;
- les risques résiduels ;
- les arbitrages coût / performance / sécurité ;
- un plan d'action priorisé ;
- les limites de votre proposition.

> **Livrables de la partie 5 :** tableau de monitoring, analyse FinOps, matrice de risques sécurité, note de recommandations DSI.

---

## 8. Partie 6 — Questions théoriques

Répondez de façon courte et précise. Les réponses doivent être contextualisées au cas NovaRetail lorsque c'est pertinent.

### 8.1 Questions Cloud, Azure et exploitation

1. Expliquez la différence entre IaaS, PaaS et SaaS. Donnez un exemple Azure pour chacun.
2. Pourquoi est-il préférable d'utiliser une base de données managée plutôt qu'une base installée manuellement sur une VM dans ce cas ?
3. Quel est le rôle d'un Virtual Network dans Azure ?
4. Quelle est la différence entre un Network Security Group et une règle RBAC ?
5. Pourquoi l'Infrastructure as Code réduit-elle les risques d'exploitation ?
6. Que contient le state Terraform et pourquoi doit-il être protégé ?
7. Expliquez la différence entre monitoring, logs et alertes.
8. Donnez trois exemples de métriques utiles pour piloter une application web.
9. Pourquoi les tags sont-ils essentiels pour le FinOps ?
10. Donnez trois mesures de sécurité prioritaires avant une mise en production.

### 8.2 Questions courtes — traçabilité blockchain

Ces questions vérifient la compréhension des principes de base liés à la traçabilité, à l'intégrité et à la sécurité des transactions dans un SI. Les réponses attendues sont courtes mais justifiées.

11. Quel est l'objectif principal d'une blockchain dans un système d'information ?
12. Quel composant permet de détecter qu'une donnée a été modifiée ? Expliquez son principe en une phrase.
13. Pourquoi dit-on qu'une blockchain est append-only ?
14. Hyperledger Fabric est surtout adapté à quel type de contexte d'entreprise ?
15. Ethereum est principalement adapté à quels usages ?
16. Azure Confidential Ledger peut être utilisé pour répondre à quel besoin de traçabilité ou d'intégrité ?
17. Quel est le rôle d'un smart contract dans une solution blockchain ?
18. Pourquoi stocke-t-on généralement les documents lourds ou sensibles off-chain plutôt que directement dans la blockchain ?
19. Que peut provoquer la compromission d'une clé privée ?
20. Quelle bonne pratique recommanderiez-vous pour les données personnelles dans une solution de traçabilité blockchain ?

---

## 9. Barème

| Partie | Points | Critères principaux |
|---|---|---|
| Analyse de l'existant et architecture cible | 3 pts | Pertinence de l'analyse, choix des services, schéma cohérent, justification des flux |
| Diagnostic d'architecture défectueuse | 3 pts | Identification des anomalies, priorisation, corrections proposées, plan de vérification |
| Déploiement et Infrastructure as Code | 4 pts | Structure Terraform, ressources attendues, variables, outputs, validation, clarté du code |
| Administration et automatisation | 2 pts | Inventaire, tags, script ou pseudo-script utile, logique d'exploitation |
| Monitoring, FinOps et sécurité | 5 pts | Métriques, alertes, coûts, risques, mesures correctives, plan d'action |
| Questions théoriques, dont notions de traçabilité blockchain | 2 pts | Exactitude, précision, contextualisation, compréhension des notions C26 |
| Qualité du dossier final | 1 pt | Lisibilité, structure, preuves, cohérence générale |
| **Total** | **20 pts** | |

---

## 10. Liste de contrôle avant remise

Avant de déposer votre dossier, vérifiez que vous avez fourni :

- [ ] le rapport final PDF ;
- [ ] le schéma d'architecture ;
- [ ] le tableau d'analyse de l'existant ;
- [ ] le tableau de choix des services ;
- [ ] le tableau de diagnostic de l'architecture défectueuse ;
- [ ] la matrice de priorisation des risques ;
- [ ] le dossier Terraform ;
- [ ] les captures de validation ;
- [ ] l'inventaire des ressources ;
- [ ] la stratégie de tags ;
- [ ] le dispositif de monitoring ;
- [ ] l'analyse FinOps ;
- [ ] la matrice de risques sécurité ;
- [ ] la note de recommandations DSI ;
- [ ] les réponses aux questions théoriques, y compris les questions de traçabilité blockchain.
