# TP4 — Monitoring, FinOps et sécurisation d'une architecture cloud

> **Bloc 4 — Optimisation du SI par l'apport du Cloud Computing**
> Parcours Mastère Dev Manager Full Stack — Plateforme Microsoft Azure
> Cas fil rouge : **ShopEasy**
>
> - **Thème :** exploitation, observabilité, coûts et sécurité
> - **Compétences visées :** C21, C24, C25, C26
> - **Prérequis :** TP1 Azure, TP2 Azure et TP3 Azure (ou environnement équivalent)
> - **Livrable final :** note de recommandations DSI + preuves d'exploitation

> Transcription Markdown du sujet PDF `TP4_MonitoringFinOpsSecurite_Azure.pdf`.

---

## 1. Positionnement du TP

Ce TP prolonge les travaux précédents sur Azure. Les apprenants ont déjà découvert l'architecture cloud, l'Infrastructure as Code et l'administration opérationnelle. Cette dernière séquence transforme l'environnement technique en un système exploitable, surveillé, maîtrisé en coûts et sécurisé.

Le fil rouge reste l'application **ShopEasy**, une application de gestion commerciale migrée vers Azure. L'objectif n'est plus seulement de déployer des ressources, mais de vérifier que l'architecture peut être exploitée par une équipe SI dans des conditions proches du réel.

### Objectif général

Mettre en place les premiers éléments de monitoring, de FinOps et de sécurité sur une architecture Azure afin de produire une **note de recommandations pour la DSI**.

### Compétences travaillées

| Code | Compétence travaillée dans ce TP |
|---|---|
| **C21** | Intégrer des services cloud en tenant compte de l'impact financier et des contraintes opérationnelles. |
| **C24** | Analyser et optimiser la performance des systèmes cloud grâce aux métriques, alertes et tableaux de bord. |
| **C25** | Appliquer des bonnes pratiques de sécurité cloud : identités, réseau, audit, moindre privilège. |
| **C26** | Formuler des recommandations d'optimisation du SI à partir des constats techniques, de coût et de sécurité. |

### Ce que les apprenants vont produire

À la fin du TP, chaque groupe devra remettre :

1. un tableau des indicateurs de supervision retenus ;
2. un tableau de bord Azure Monitor ou une proposition de dashboard documentée ;
3. au moins deux alertes configurées ou documentées ;
4. une analyse FinOps de l'environnement ;
5. une revue de sécurité Azure ;
6. une note de recommandations pour la DSI ;
7. les captures d'écran ou extraits justifiant les contrôles effectués.

> **Attention.** Les ressources cloud peuvent générer des coûts. Les apprenants doivent supprimer les ressources non nécessaires à la fin des manipulations et vérifier le groupe de ressources utilisé.

---

## 2. Rappels théoriques courts

Cette partie sert de point d'appui. Elle ne remplace pas le cours magistral associé. Les notions ci-dessous doivent permettre de comprendre les manipulations du TP.

### 2.1 Monitoring, observabilité et exploitation

Le **monitoring** consiste à surveiller l'état d'un système à partir de signaux mesurables : CPU, mémoire, erreurs, latence, disponibilité, consommation réseau, coûts. Il répond principalement à la question : *le système fonctionne-t-il correctement ?*

L'**observabilité** va plus loin. Elle vise à comprendre *pourquoi* un système se comporte d'une certaine façon en combinant plusieurs signaux : métriques, journaux, traces, événements, activité utilisateur et coûts.

| Notion | Objectif | Exemple Azure |
|---|---|---|
| Métrique | Mesurer un état numérique | CPU d'une VM, stockage utilisé, latence |
| Log | Comprendre un événement ou une activité | logs système, logs applicatifs, Activity Log |
| Alerte | Déclencher une action sur seuil ou événement | CPU élevé, budget dépassé, service indisponible |
| Dashboard | Donner une vue de pilotage | Azure Dashboard, Workbook, rapport d'exploitation |

### 2.2 FinOps

Le **FinOps** est une discipline qui permet de piloter les coûts cloud de manière continue. Il ne s'agit pas seulement de réduire les dépenses, mais de maximiser la valeur produite par les ressources consommées. Les principes principaux sont :

- visibilité des coûts ;
- responsabilisation des équipes ;
- usage systématique des tags ;
- suppression des ressources inutiles ;
- dimensionnement adapté ;
- alertes budgétaires ;
- arbitrage coût, performance, sécurité et disponibilité.

### 2.3 Sécurité cloud

La sécurité cloud repose sur le **modèle de responsabilité partagée**. Microsoft sécurise l'infrastructure physique et les services managés. Le client reste responsable de la configuration de ses ressources, de ses identités, de ses données, de ses accès et de ses politiques. Dans ce TP, l'attention porte principalement sur :

- les droits Azure RBAC ;
- la surface d'exposition réseau ;
- les Network Security Groups ;
- les ressources exposées publiquement ;
- les logs d'activité ;
- le chiffrement ;
- les recommandations de sécurité.

---

## 3. Contexte fil rouge : ShopEasy

ShopEasy a migré une application web de gestion de commandes vers Azure. L'architecture cible comprend les briques suivantes :

- un groupe de ressources dédié ;
- un Virtual Network ;
- un ou plusieurs subnets ;
- des machines virtuelles Linux ;
- des Network Security Groups ;
- un Storage Account ;
- une base de données Azure SQL ou une base managée équivalente ;
- Azure Monitor pour l'observabilité ;
- Cost Management pour le suivi financier ;
- RBAC et Microsoft Entra ID pour les accès.

La DSI demande maintenant une **analyse opérationnelle** :

> L'architecture est-elle surveillée ? Peut-on détecter un incident ? Peut-on maîtriser les coûts ? Les accès et les ressources exposées sont-ils sécurisés ? Quelles actions faut-il prioriser avant une mise en production ?

---

## 4. Atelier 1 — Cadrer les indicateurs d'exploitation

**Objectif.** Avant de configurer un outil, il faut savoir quoi surveiller. Dans cet atelier, les apprenants définissent les indicateurs pertinents pour ShopEasy.

**Travail demandé.** Compléter le tableau suivant. Les indicateurs doivent couvrir à la fois la performance, la disponibilité, les coûts et la sécurité.

| Domaine | Indicateur | Seuil proposé | Justification |
|---|---|---|---|
| Disponibilité | | | |
| Performance | | | |
| Coût | | | |
| Sécurité | | | |
| Exploitation | | | |

**Questions guidées.**

1. Pourquoi ne faut-il pas surveiller uniquement le CPU ?
2. Quels indicateurs permettent de détecter un risque de saturation ?
3. Quels indicateurs permettent d'identifier une dérive de coûts ?
4. Quels signaux permettent de détecter un problème de sécurité ?
5. Quelle différence faites-vous entre un incident, une alerte et une recommandation ?

**Livrable attendu.** Un tableau d'indicateurs priorisés avec une justification claire pour chaque indicateur retenu.

---

## 5. Atelier 2 — Préparer l'environnement Azure Monitor

**Objectif.** Mettre en place la base de l'observabilité Azure avec un espace Log Analytics, des diagnostics et une organisation claire des ressources.

**Ressources à identifier :** groupe de ressources du projet, machines virtuelles, Network Security Groups, Storage Account, base de données, réseau virtuel, ressources de monitoring existantes.

**Exemples de commandes utiles :**

```bash
az login
az account show
az group list --output table
az resource list --resource-group <nom-rg> --output table
```

**Log Analytics Workspace.** Créer ou identifier un Log Analytics Workspace. Ce workspace servira à centraliser les logs et à faciliter les recherches opérationnelles.

```bash
az monitor log-analytics workspace create \
  --resource-group <nom-rg> \
  --workspace-name law-shopeasy-dev \
  --location francecentral
```

**Diagnostic settings.** Pour chaque ressource critique, vérifier si les logs et métriques peuvent être envoyés vers Log Analytics. L'objectif est de préparer une vision d'exploitation centralisée.

| Ressource | Diagnostics attendus | Intérêt opérationnel |
|---|---|---|
| VM | Métriques, logs système | Détecter surcharge et indisponibilité |
| Storage Account | Transactions, erreurs, capacité | Surveiller activité et coûts |
| Azure SQL | CPU, DTU/vCore, connexions | Détecter saturation base |
| Activity Log | Opérations administratives | Auditer les changements |

**Livrable attendu.** Capture ou description de l'espace Log Analytics, liste des ressources connectées ou à connecter, et justification des choix.

---

## 6. Atelier 3 — Superviser les machines virtuelles

**Objectif.** Analyser l'état des machines virtuelles et construire une première vision de supervision.

**Métriques à observer** (pour chaque VM, dans Azure Monitor) : pourcentage CPU, réseau entrant et sortant, disque lu/écrit, disponibilité de la VM, erreurs éventuelles, statut de démarrage.

**Commandes d'inventaire :**

```bash
az vm list --resource-group <nom-rg> --show-details --output table
az vm get-instance-view --resource-group <nom-rg> --name <nom-vm> --output table
```

**Questions d'analyse.**

1. La VM est-elle correctement dimensionnée ?
2. Les métriques disponibles suffisent-elles à diagnostiquer un incident applicatif ?
3. Quelles métriques manquent pour une supervision applicative complète ?
4. Que faudrait-il ajouter pour connaître la disponibilité réelle vue par un utilisateur ?

**Tableau d'analyse des VM :**

| VM | État | Risque observé | Action proposée |
|---|---|---|---|
| | | | |

**Livrable attendu.** Un tableau d'analyse des VM avec au moins deux recommandations d'exploitation.

---

## 7. Atelier 4 — Créer des alertes opérationnelles

**Objectif.** Configurer ou documenter des alertes permettant de détecter rapidement un incident.

**Alertes attendues** (au moins deux parmi) : CPU moyen d'une VM supérieur à un seuil ; VM arrêtée ou indisponible ; consommation stockage anormale ; coût prévisionnel supérieur au budget ; modification critique détectée dans l'Activity Log ; nombre d'erreurs applicatives anormal (si l'application le permet).

**Exemple de logique d'alerte :**

| Alerte | Seuil | Criticité | Action attendue |
|---|---|---|---|
| CPU élevé VM Web | > 70 % | Moyenne | Vérifier charge, logs et dimensionnement |
| VM indisponible | État KO | Haute | Redémarrage, escalade, analyse incident |
| Budget dépassé | > 80 % | Moyenne | Analyse coûts, suppression ressources inutiles |

**Action Group.** Un Action Group définit qui est notifié et comment. Dans un contexte réel, il peut notifier par mail, webhook, ITSM ou canal d'exploitation.

```bash
az monitor action-group create \
  --resource-group <nom-rg> \
  --name ag-shopeasy-ops \
  --short-name shopops \
  --email-receiver name=EquipeOps email=<email>
```

**Questions d'analyse.**

1. Quel risque y a-t-il à définir des seuils trop bas ?
2. Quel risque y a-t-il à définir des seuils trop hauts ?
3. Pourquoi faut-il documenter une action attendue pour chaque alerte ?
4. Comment éviter la fatigue d'alerte ?

**Livrable attendu.** Une fiche d'alerte avec : nom, ressource cible, seuil, criticité, destinataire et procédure de réaction.

---

## 8. Atelier 5 — Construire un tableau de bord d'exploitation

**Objectif.** Créer une vue synthétique permettant à une équipe SI de suivre l'état de l'application ShopEasy.

**Contenu minimal du dashboard :** état des VM, CPU des VM, trafic réseau, stockage consommé, état de la base de données, coûts ou budget, alertes récentes, lien vers les journaux ou l'Activity Log.

**Travail attendu.** Les apprenants peuvent créer un dashboard dans Azure Portal ou proposer une maquette si certaines ressources ne sont pas disponibles.

| Tuile du dashboard | Source de données | Décision facilitée |
|---|---|---|
| État des VM | Azure Monitor | Détecter une indisponibilité |
| CPU des VM | Metrics | Identifier surcharge |
| Coûts | Cost Management | Piloter budget |
| Alertes | Azure Monitor Alerts | Prioriser les incidents |

**Livrable attendu.** Capture du dashboard ou maquette détaillée avec justification de chaque tuile.

---

## 9. Atelier 6 — Analyse FinOps

**Objectif.** Comprendre les coûts de l'environnement et proposer des optimisations réalistes.

**Analyse à réaliser** (dans Cost Management) : coût par groupe de ressources, coût par type de service, coût par ressource, ressources sans tag, coût prévisionnel, recommandations d'optimisation éventuelles.

**Tags de gouvernance.** Proposer une politique de tags minimale pour ShopEasy.

| Tag | Exemple | Utilité |
|---|---|---|
| Application | ShopEasy | Regrouper les coûts par application |
| Environment | dev, test, prod | Distinguer les environnements |
| Owner | equipe-cloud | Identifier le responsable |
| CostCenter | DSI-Cloud | Affecter les coûts |
| Criticality | low, medium, high | Prioriser supervision et sécurité |

**Commandes utiles pour les tags :**

```bash
az resource tag \
  --ids <resource-id> \
  --tags Application=ShopEasy Environment=dev Owner=equipe-cloud
```

**Tableau d'optimisation FinOps :**

| Constat | Risque financier | Priorité | Action proposée |
|---|---|---|---|
| VM sous-utilisée | Dépense inutile | | |
| Disque non attaché | Coût oublié | | |
| Ressource sans tag | Coût non pilotable | | |
| Pas de budget | Dérive non détectée | | |

**Questions d'analyse.**

1. Pourquoi le cloud peut-il coûter plus cher que prévu ?
2. Quelles ressources doivent être arrêtées hors période d'utilisation ?
3. Pourquoi les tags sont-ils indispensables pour une DSI ?
4. Quelle différence faites-vous entre réduction de coût et optimisation de valeur ?

**Livrable attendu.** Une analyse FinOps structurée avec au moins cinq constats et cinq actions correctives.

---

## 10. Atelier 7 — Revue de sécurité Azure

**Objectif.** Identifier les principaux risques de sécurité de l'environnement et proposer un plan d'amélioration.

**Points de contrôle :** rôles attribués dans le groupe de ressources, utilisateurs ayant des droits élevés, présence de ressources exposées publiquement, règles NSG trop ouvertes, accès SSH ou RDP depuis Internet, chiffrement du stockage, logs d'activité disponibles, recommandations de sécurité dans Azure Advisor ou Defender for Cloud.

**Contrôle RBAC :**

```bash
az role assignment list \
  --resource-group <nom-rg> \
  --output table
```

**Contrôle NSG :**

```bash
az network nsg list --resource-group <nom-rg> --output table
az network nsg rule list \
  --resource-group <nom-rg> \
  --nsg-name <nom-nsg> \
  --output table
```

**Matrice de risques :**

| Risque | Impact | Probabilité | Mesure corrective |
|---|---|---|---|
| Port SSH ouvert à Internet | Élevé | | Restreindre à une IP ou utiliser Bastion |
| Droits Owner trop larges | Élevé | | Appliquer le moindre privilège |
| Storage public | Élevé | | Bloquer l'accès public et auditer les permissions |
| Pas de logs | Moyen | | Activer diagnostics et Activity Log |
| Pas de tags | Moyen | | Appliquer politique de gouvernance |

**Livrable attendu.** Une matrice de risques sécurité avec au moins cinq risques, leur criticité et les mesures correctives proposées.

---

## 11. Atelier 8 — Audit des changements et Activity Log

**Objectif.** Exploiter les journaux d'activité Azure pour comprendre ce qui a changé dans l'environnement.

**Travail demandé.** Dans l'Activity Log, identifier : les créations de ressources, les suppressions de ressources, les modifications de configuration, les changements de droits, les erreurs ou opérations échouées.

**Questions d'analyse.**

1. Pourquoi l'Activity Log est-il important pour l'audit ?
2. Quelle différence y a-t-il entre un log technique et un log d'activité ?
3. Quelle information manque parfois pour reconstituer un incident ?
4. Comment une DSI peut-elle exploiter ces logs dans une démarche de contrôle interne ?

**Livrable attendu.** Une fiche d'audit listant trois événements significatifs observés et leur interprétation.

---

## 12. Atelier 9 — Plan d'amélioration avant production

**Objectif.** Transformer les constats techniques en recommandations de décision pour une DSI.

**Format attendu.** Rédiger une note courte structurée ainsi :

1. contexte et objectif ;
2. état actuel de l'exploitation ;
3. alertes et monitoring proposés ;
4. analyse FinOps ;
5. analyse sécurité ;
6. risques résiduels ;
7. plan d'action priorisé ;
8. conclusion.

**Plan d'action priorisé :**

| Action | Priorité | Responsable | Gain attendu |
|---|---|---|---|
| Activer alertes critiques | Haute | Équipe Cloud | Détection incident |
| Restreindre SSH | Haute | Sécurité/Ops | Réduction surface d'attaque |
| Ajouter tags obligatoires | Moyenne | Équipe projet | Pilotage coûts |
| Créer budget Azure | Moyenne | FinOps | Contrôle dépenses |
| Créer dashboard DSI | Moyenne | Ops | Suivi opérationnel |

**Livrable attendu.** Une note de recommandations DSI claire, argumentée et exploitable.

---

## 13. Livrables à remettre

| N | Livrable | Format attendu |
|---|---|---|
| 1 | Tableau des indicateurs de supervision | PDF ou document texte |
| 2 | Captures ou description Azure Monitor / Log Analytics | PDF |
| 3 | Fiche d'alerte opérationnelle | Tableau ou capture |
| 4 | Dashboard ou maquette de dashboard | Capture ou schéma |
| 5 | Analyse FinOps | Tableau commenté |
| 6 | Matrice de risques sécurité | Tableau |
| 7 | Fiche d'audit Activity Log | Tableau court |
| 8 | Note de recommandations DSI | 1 à 2 pages |

---

## 14. Quiz de validation

1. Quelle différence faites-vous entre monitoring et observabilité ?
2. À quoi sert Azure Monitor ?
3. Quel est le rôle d'un Log Analytics Workspace ?
4. Pourquoi faut-il définir des seuils d'alerte avec prudence ?
5. Qu'est-ce qu'un Action Group ?
6. Pourquoi les tags sont-ils importants en FinOps ?
7. Quel service Azure permet de suivre les coûts ?
8. Pourquoi une ressource sans tag pose-t-elle un problème ?
9. Quel risque présente un port SSH ouvert à Internet ?
10. Que signifie le principe du moindre privilège ?
11. Quel journal permet de suivre les modifications réalisées sur les ressources Azure ?
12. Pourquoi faut-il surveiller les droits RBAC ?
13. Citez deux exemples de métriques utiles pour une VM.
14. Citez deux exemples de recommandations de sécurité.
15. Pourquoi une alerte doit-elle être associée à une procédure d'action ?
16. Quelle différence faites-vous entre coût constaté et coût prévisionnel ?
17. Pourquoi le chiffrement ne suffit-il pas à lui seul à sécuriser une ressource ?
18. Quel est l'intérêt d'un tableau de bord pour une DSI ?
19. Qu'est-ce qu'une dérive de coût cloud ?
20. Donnez trois actions prioritaires avant une mise en production.

---

## 15. Grille d'évaluation indicative

| Critère | Points | Attendus |
|---|---|---|
| Choix des indicateurs de supervision | 3 | Indicateurs pertinents et justifiés |
| Configuration ou documentation des alertes | 3 | Alertes exploitables et procédures claires |
| Dashboard ou maquette d'exploitation | 2 | Vue claire pour le pilotage |
| Analyse FinOps | 3 | Constats concrets et actions réalistes |
| Analyse de sécurité | 4 | Risques identifiés, criticité et corrections |
| Exploitation de l'Activity Log | 2 | Événements interprétés correctement |
| Note de recommandations DSI | 3 | Structure, priorisation, argumentation |
| **Total** | **20** | |

---

## 16. Corrigé indicatif

**Indicateurs attendus.** Un bon tableau d'indicateurs doit couvrir au minimum : disponibilité des VM ; CPU et consommation réseau ; stockage utilisé ; coût mensuel et coût prévisionnel ; alertes récentes ; modifications administratives ; ressources exposées publiquement ; droits RBAC sensibles.

**Alertes attendues.** Deux alertes minimales pertinentes : CPU VM supérieur à 70 % pendant une période prolongée ; budget consommé supérieur à 80 % ; port critique ouvert ou modification d'une règle NSG ; VM arrêtée ou indisponible.

**Analyse FinOps attendue.** Les recommandations FinOps doivent inclure : ajout de tags obligatoires ; création d'un budget ; suppression des ressources inutilisées ; vérification des tailles de VM ; extinction des environnements de test quand ils ne sont pas utilisés ; analyse des disques non attachés ; revue régulière des recommandations Azure Advisor.

**Analyse sécurité attendue.** Refus des règles NSG ouvertes sur Internet sauf justification ; restriction SSH/RDP ; application du moindre privilège RBAC ; activation ou conservation des journaux d'activité ; blocage de l'accès public inutile aux comptes de stockage ; prise en compte du chiffrement ; priorisation des recommandations critiques.

**Note DSI attendue.** Une bonne note ne se limite pas à une liste de ressources techniques. Elle doit mettre en relation les constats avec des impacts métier : indisponibilité, coûts non maîtrisés, risques de sécurité, difficulté d'exploitation.

> *Exemple de conclusion attendue :* L'environnement ShopEasy dispose d'une base technique exploitable, mais il doit être renforcé avant toute mise en production. Les priorités sont la mise en place d'alertes critiques, la restriction des accès réseau, l'application du moindre privilège, la création d'un budget Azure et la formalisation d'un tableau de bord d'exploitation. Ces actions permettent de réduire le risque opérationnel, d'améliorer la visibilité DSI et de maîtriser les coûts cloud.

---

## 17. Nettoyage des ressources

À la fin du TP, vérifier les ressources restantes afin d'éviter des coûts inutiles.

```bash
az resource list --resource-group <nom-rg> --output table
az group delete --name <nom-rg> --yes --no-wait
```

> **Attention.** Ne pas supprimer un groupe de ressources partagé ou utilisé par d'autres TP sans validation de l'enseignant.

> **Note Azure for Students.** Le sujet utilise `francecentral` dans ses exemples. Pour l'abonnement *Azure for Students* de ShopEasy, la région retenue est **`swedencentral`** (`francecentral` interdite par policy) et les VM sont en **`Standard_B2ts_v2`**, comme aux TP2 et TP3.
