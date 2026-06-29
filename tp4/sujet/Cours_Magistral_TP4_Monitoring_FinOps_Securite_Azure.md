# Cours magistral TP4 — Monitoring, FinOps et sécurité Azure

> **Bloc 4 — Optimisation du SI par l'apport du Cloud Computing**
> Version Azure — Support théorique associé au TP4 — Mastère Dev Manager Full Stack (RNCP 7)
>
> **Finalité.** Comprendre comment piloter une infrastructure Azure après son déploiement : observer l'état du système, maîtriser les coûts, sécuriser les ressources, produire des recommandations et préparer une mise en production fiable.

> Transcription Markdown du PDF `Cours_Magistral_TP4_Monitoring_FinOps_Securite_Azure.pdf`.

---

## 1. Positionnement du cours

Ce cours magistral accompagne le TP4 consacré à l'exploitation d'une architecture Azure déjà déployée. Les TP précédents ont permis de concevoir une architecture cible, d'introduire Terraform pour l'Infrastructure as Code, puis d'administrer l'environnement avec Azure CLI, Bash et Python. Le TP4 se place dans une logique de passage vers l'exploitation, la supervision, le contrôle des coûts, l'audit et la sécurisation.

**Objectifs pédagogiques.** À l'issue de ce cours, l'apprenant doit être capable de :

- expliquer la différence entre monitoring, observabilité, audit et sécurité opérationnelle ;
- identifier les composants Azure utiles à la supervision d'une application ;
- choisir des indicateurs pertinents pour piloter disponibilité, performance, coût et sécurité ;
- comprendre le rôle d'Azure Monitor, Log Analytics, alertes, dashboards et Activity Log ;
- expliquer les principes FinOps appliqués à Azure ;
- analyser les risques de sécurité et proposer des mesures correctives ;
- formuler une note de recommandations pour une DSI.

### 1.1 Lien avec le TP4

Le TP4 demande à l'étudiant de mettre en place un dispositif de monitoring, de contrôler les coûts, d'analyser la posture de sécurité, puis de produire un plan d'amélioration. Ce cours fournit donc le cadre conceptuel nécessaire avant les manipulations.

> **À retenir.** Le TP4 n'est pas seulement un exercice technique. Il apprend à raisonner comme une équipe d'exploitation cloud : observer, détecter, diagnostiquer, alerter, optimiser, sécuriser et documenter.

### 1.2 Compétences visées

| Compétence | Contribution du TP4 et du cours associé |
|---|---|
| C21 | Relier les choix cloud aux impacts financiers, opérationnels et écologiques. |
| C24 | Mettre en place des outils de monitoring et analyser les performances. |
| C25 | Identifier les risques de sécurité, appliquer le moindre privilège et auditer les traces. |
| C26 | Formuler des recommandations d'optimisation du SI pour une DSI. |

---

## 2. Exploitation cloud : passer du déploiement au pilotage

Déployer une infrastructure n'est qu'une première étape. Une plateforme cloud doit ensuite être exploitée. L'exploitation regroupe l'ensemble des activités permettant de maintenir le service disponible, sécurisé, performant et économiquement soutenable.

### 2.1 Les objectifs de l'exploitation

- **Disponibilité :** le service doit être accessible lorsque les utilisateurs en ont besoin.
- **Performance :** les temps de réponse doivent rester acceptables.
- **Sécurité :** les accès, données et configurations doivent être maîtrisés.
- **Maintenabilité :** l'équipe doit pouvoir diagnostiquer et corriger rapidement.
- **Maîtrise des coûts :** la consommation cloud doit rester lisible et justifiée.
- **Traçabilité :** les actions importantes doivent être historisées et exploitables.

### 2.2 Une nouvelle culture opérationnelle

Dans un modèle cloud, l'infrastructure devient dynamique. Les ressources peuvent être créées, modifiées ou détruites rapidement. Cette souplesse est un avantage, mais elle augmente aussi les risques : ressources oubliées, droits trop larges, dépenses inattendues, absence de supervision, faible traçabilité.

> **Point d'attention.** Un environnement cloud non surveillé peut fonctionner correctement en apparence tout en accumulant des risques : coûts cachés, absence de sauvegarde, ports ouverts, droits excessifs, logs non collectés, alertes inexistantes.

---

## 3. Monitoring, observabilité et audit

### 3.1 Monitoring

Le monitoring consiste à collecter et surveiller des indicateurs afin de vérifier que le système fonctionne normalement. Il répond principalement aux questions : le service est-il disponible ? Les ressources sont-elles saturées ? Une erreur critique s'est-elle produite ? Un seuil de coût ou de consommation a-t-il été dépassé ? Le monitoring repose souvent sur des métriques, des logs, des tableaux de bord et des alertes.

### 3.2 Observabilité

L'observabilité va plus loin que le monitoring. Elle vise à comprendre l'état interne d'un système à partir des signaux qu'il produit. Elle devient essentielle lorsque les architectures deviennent distribuées, dynamiques et composées de nombreux services.

| Concept | Question centrale | Exemple |
|---|---|---|
| Monitoring | Est-ce que cela fonctionne ? | La CPU d'une VM dépasse 85 %. |
| Observabilité | Pourquoi cela ne fonctionne pas ? | Les logs montrent une erreur de connexion à la base. |
| Audit | Qui a fait quoi ? | Un utilisateur a modifié une règle réseau. |
| Sécurité | Le système est-il protégé ? | Un port d'administration est exposé à Internet. |

### 3.3 Les trois signaux classiques

- **Métriques :** valeurs numériques mesurées dans le temps (CPU, mémoire, latence, nombre de requêtes).
- **Logs :** événements textuels produits par une application, une ressource ou une plateforme.
- **Traces :** suivi d'une requête à travers plusieurs composants applicatifs.

> **À retenir.** Une métrique indique souvent qu'un problème existe. Un log aide à comprendre le contexte. Une trace permet de suivre le chemin d'une requête dans un système distribué.

---

## 4. Azure Monitor : rôle et architecture conceptuelle

Azure Monitor est le service central de supervision d'Azure. Il collecte, analyse et exploite des données de monitoring provenant des ressources Azure, des applications et parfois d'environnements hybrides.

### 4.1 Vue d'ensemble

| Sources Azure | Collecte | Analyse | Action |
|---|---|---|---|
| VM, SQL, Storage, VNet | Metrics, logs, events | Dashboards, requêtes, workbooks | Alertes, tickets, corrections |

### 4.2 Les composants principaux

| Composant | Rôle |
|---|---|
| Azure Monitor Metrics | Stockage et analyse de métriques numériques dans le temps. |
| Azure Monitor Logs | Centralisation et analyse de logs dans un workspace Log Analytics. |
| Log Analytics Workspace | Espace de travail permettant de stocker, interroger et corréler les logs. |
| Alert Rules | Règles de déclenchement lorsqu'une condition est atteinte. |
| Action Groups | Destinataires ou actions associés à une alerte. |
| Workbooks | Rapports interactifs combinant texte, visualisations et requêtes. |
| Dashboards | Tableaux de bord synthétiques dans le portail Azure. |
| Activity Log | Journal des opérations effectuées sur les ressources Azure. |

### 4.3 Métriques vs logs

| Critère | Métriques | Logs |
|---|---|---|
| Nature | Données numériques agrégées | Événements détaillés |
| Granularité | Souvent périodique | Variable selon les événements |
| Usage typique | Alerte rapide sur seuil | Diagnostic et investigation |
| Exemple | CPU moyen supérieur à 80 % | Erreur applicative ou changement de configuration |
| Coût | Généralement plus prévisible | Dépendance au volume ingéré et conservé |

---

## 5. Construire une stratégie de monitoring

### 5.1 Ne pas tout surveiller de la même manière

Un piège classique consiste à vouloir surveiller toutes les métriques sans priorisation. Une stratégie de monitoring efficace commence par les objectifs métier et opérationnels.

> **Question à poser avant de créer une alerte.** Si cette alerte se déclenche, une personne doit-elle vraiment agir ? Si la réponse est non, il s'agit probablement d'une information à afficher dans un dashboard, pas d'une alerte.

### 5.2 Les indicateurs essentiels

| Axe | Indicateurs possibles | Interprétation |
|---|---|---|
| Disponibilité | État des VM, taux d'erreur HTTP, statut des services | Identifier une indisponibilité ou une dégradation majeure. |
| Performance | CPU, mémoire, disque, latence, temps de réponse | Détecter saturation et sous-dimensionnement. |
| Capacité | Taille stockage, nombre de requêtes, connexions base | Anticiper la croissance. |
| Sécurité | Connexions suspectes, changements IAM/RBAC, ports exposés | Détecter des comportements anormaux. |
| Coût | Coût par service, coût par tag, budget consommé | Éviter les dérives financières. |
| Qualité d'exploitation | Nombre d'incidents, temps de résolution, alertes critiques | Piloter l'efficacité opérationnelle. |

### 5.3 SLI, SLO et SLA

- **SLI — Service Level Indicator :** indicateur mesurable, par exemple le taux de disponibilité.
- **SLO — Service Level Objective :** objectif interne fixé sur un indicateur, par exemple 99,5 % de disponibilité mensuelle.
- **SLA — Service Level Agreement :** engagement contractuel avec un client ou un partenaire.

> **À retenir.** Un tableau de bord utile ne se limite pas à des courbes techniques. Il doit répondre à des questions de pilotage : le service fonctionne-t-il, coûte-t-il trop cher, est-il sécurisé, que faut-il corriger en priorité ?

---

## 6. Alertes et gestion des incidents

### 6.1 Rôle d'une alerte

Une alerte doit transformer une observation en action. Elle doit être associée à un destinataire, une criticité et une procédure de traitement.

| Élément | Description |
|---|---|
| Condition | Situation qui déclenche l'alerte : seuil CPU, service indisponible, coût anormal. |
| Période | Durée ou fenêtre d'évaluation. |
| Sévérité | Niveau de gravité : critique, majeur, mineur, information. |
| Action group | Personnes ou outils à notifier. |
| Runbook | Procédure de diagnostic et correction. |

### 6.2 Éviter la fatigue d'alerte

Trop d'alertes tue l'alerte. Lorsqu'une équipe reçoit trop de notifications non prioritaires, elle finit par les ignorer. Il faut donc distinguer : les alertes critiques nécessitant une action immédiate ; les alertes d'avertissement nécessitant une analyse ; les informations utiles uniquement en reporting.

### 6.3 Cycle de gestion d'incident

`Détecter → Qualifier → Diagnostiquer → Corriger → Capitaliser`

---

## 7. FinOps sur Azure

### 7.1 Définition

FinOps combine finance, technologie et opérations pour permettre aux organisations de comprendre, piloter et optimiser leurs dépenses cloud. Ce n'est pas seulement une démarche de réduction de coûts : il s'agit de maximiser la valeur du cloud par rapport à son coût.

### 7.2 Pourquoi le cloud change la gestion budgétaire

Dans un datacenter traditionnel, les coûts sont principalement engagés à l'achat. Dans le cloud, les coûts apparaissent au fil de la consommation. Cette consommation peut varier rapidement selon l'activité, les erreurs de configuration ou les ressources oubliées.

> **Point d'attention.** Le cloud rend la dépense plus flexible, mais aussi plus facile à disperser. Sans tags, budgets, alertes et gouvernance, il devient difficile de savoir qui consomme quoi, pourquoi et avec quelle valeur métier.

### 7.3 Les trois grands objectifs FinOps

1. **Rendre les coûts visibles :** comprendre les dépenses par service, projet, équipe, environnement.
2. **Responsabiliser les équipes :** associer la consommation à des usages et à des propriétaires.
3. **Optimiser en continu :** ajuster ressources, architectures, modes de facturation et pratiques.

### 7.4 Outils Azure utiles au FinOps

| Outil | Rôle |
|---|---|
| Cost Management | Analyse, suivi et optimisation des coûts Azure. |
| Budgets | Définition de seuils financiers et notifications. |
| Cost alerts | Notification lors de dépassements ou anomalies. |
| Azure Pricing Calculator | Estimation avant déploiement. |
| Tags | Affectation des coûts par projet, application, équipe ou environnement. |
| Reservations et savings plans | Réduction potentielle pour des usages prévisibles. |
| Advisor | Recommandations d'optimisation, de coût, de sécurité et de performance. |

### 7.5 Axes d'optimisation courants

- supprimer les ressources non utilisées ;
- éteindre les environnements hors production lorsqu'ils ne sont pas nécessaires ;
- redimensionner les VM surdimensionnées ;
- choisir le bon niveau de service de stockage ou de base de données ;
- utiliser des réservations ou plans d'économie lorsque l'usage est stable ;
- mettre en place des budgets et alertes par environnement ;
- rendre les tags obligatoires.

> **À retenir.** Une bonne recommandation FinOps ne dit pas seulement « réduire les coûts ». Elle précise la ressource concernée, le problème, l'impact estimé, le risque et l'action proposée.

---

## 8. Sécurité Azure : principes fondamentaux

### 8.1 Modèle de responsabilité partagée

Dans le cloud, la sécurité est partagée entre le fournisseur et le client. Azure sécurise l'infrastructure physique, certains services managés et la plateforme. Le client reste responsable de la configuration, des identités, des données, des droits d'accès et des choix d'architecture.

| Responsabilité | Exemples |
|---|---|
| Fournisseur cloud | Datacenters, matériel, hyperviseur, disponibilité des services Azure. |
| Client | Comptes, rôles, données, configuration réseau, chiffrement, journalisation, gouvernance. |
| Partagée | Mises à jour, supervision, continuité d'activité selon le service utilisé. |

### 8.2 Identité et accès

La sécurité cloud commence souvent par l'identité. Dans Azure, Microsoft Entra ID et RBAC permettent de gérer qui peut accéder à quoi et avec quels droits.

- **Utilisateur :** personne physique ou compte associé.
- **Groupe :** ensemble d'utilisateurs avec des droits communs.
- **Rôle RBAC :** ensemble d'autorisations prédéfinies ou personnalisées.
- **Scope :** niveau d'application des droits (management group, subscription, resource group ou ressource).

### 8.3 Principe du moindre privilège

Le moindre privilège consiste à accorder uniquement les droits strictement nécessaires pour accomplir une tâche. Il limite l'impact d'une erreur, d'un compte compromis ou d'un mauvais usage.

> **Point d'attention.** Donner le rôle Owner par facilité est une mauvaise pratique. Le rôle Contributor ou un rôle plus restreint est souvent suffisant. Pour la lecture seule, Reader doit être privilégié.

### 8.4 Sécurité réseau

Les Network Security Groups permettent de filtrer les flux entrants et sortants au niveau des subnets ou interfaces réseau. Une bonne politique réseau limite l'exposition des ressources.

| Bonne pratique | Justification |
|---|---|
| Fermer les ports inutiles | Réduit la surface d'attaque. |
| Limiter SSH/RDP à des IP autorisées | Évite l'administration exposée publiquement. |
| Isoler les bases de données | Une base ne doit pas être accessible directement depuis Internet. |
| Segmenter les subnets | Sépare les couches web, application et données. |
| Journaliser les changements | Facilite l'audit et l'investigation. |

---

## 9. Microsoft Defender for Cloud et posture de sécurité

Microsoft Defender for Cloud aide à analyser la posture de sécurité, identifier des recommandations et protéger des workloads cloud. Dans un cours de niveau Mastère, il est important de le comprendre non comme un simple outil de scan, mais comme un composant de pilotage de la sécurité.

### 9.1 Concepts utiles

- **Secure score :** indicateur synthétique de posture de sécurité.
- **Recommendations :** actions proposées pour corriger des faiblesses.
- **Regulatory compliance :** suivi de conformité selon des cadres de référence.
- **Workload protection :** protections avancées selon les services et plans activés.

### 9.2 Lecture critique des recommandations

Toutes les recommandations ne se valent pas. Il faut les prioriser selon : l'exposition de la ressource ; la sensibilité des données ; le coût de correction ; l'impact opérationnel ; les exigences de conformité ; la criticité métier.

> **À retenir.** Une recommandation de sécurité doit être traduite en action. Une DSI attend une priorisation, pas une simple liste brute de problèmes.

---

## 10. Audit, traçabilité et preuves d'exploitation

### 10.1 Pourquoi auditer ?

L'audit permet de répondre aux questions : qui a modifié cette ressource ? Quand un changement a-t-il été effectué ? Quelle action a provoqué un incident ? Les ressources critiques sont-elles correctement journalisées ? Peut-on prouver qu'une mesure de sécurité existe ?

### 10.2 Sources de traces dans Azure

| Source | Utilité |
|---|---|
| Activity Log | Opérations de gestion sur les ressources Azure. |
| Resource Logs | Logs spécifiques produits par certains services. |
| Entra ID logs | Connexions, identités, activités liées aux comptes. |
| Diagnostic settings | Configuration d'export des logs vers Log Analytics, Storage ou Event Hub. |
| Defender for Cloud | Alertes et recommandations de sécurité. |
| Azure Policy | Conformité des ressources à des règles de gouvernance. |

### 10.3 Notion de preuve

Dans un contexte professionnel, il ne suffit pas de dire qu'une ressource est sécurisée. Il faut pouvoir le démontrer. Les preuves peuvent être : capture de configuration, export de logs, tableau de bord, rapport d'audit, historique d'activité, règle Azure Policy, preuve de revue d'accès.

---

## 11. Gouvernance Azure

### 11.1 Pourquoi gouverner ?

La gouvernance cloud vise à éviter que la flexibilité du cloud ne se transforme en désordre. Elle établit des règles de nommage, de tagging, de sécurité, de coût et de conformité.

### 11.2 Niveaux de gouvernance

| Niveau | Exemple |
|---|---|
| Management Group | Organiser plusieurs subscriptions par domaine ou entité. |
| Subscription | Isoler facturation, responsabilités ou environnements. |
| Resource Group | Regrouper les ressources d'une application ou d'un projet. |
| Tags | Suivre coût, propriétaire, criticité, environnement. |
| Azure Policy | Imposer ou auditer des règles de configuration. |
| RBAC | Contrôler les autorisations. |

### 11.3 Politique de tags recommandée

| Tag | Exemple | Utilité |
|---|---|---|
| Environment | dev, test, prod | Distinguer les usages et les budgets. |
| Owner | equipe-data, equipe-web | Identifier le responsable. |
| Application | shopeasy | Relier les ressources à une application. |
| CostCenter | FIN-001 | Affecter les coûts. |
| Criticality | low, medium, high | Prioriser incidents et sécurité. |
| DataSensitivity | public, internal, confidential | Orienter les exigences de protection. |

---

## 12. Analyse de risques cloud

### 12.1 Matrice risque / impact

Une analyse de risques consiste à identifier les scénarios défavorables, estimer leur probabilité et leur impact, puis proposer une réduction de risque.

| Risque | Impact | Cause possible | Mesure corrective |
|---|---|---|---|
| VM exposée en SSH | Compromission serveur | NSG trop permissif | Restriction IP, Bastion, MFA |
| Absence de logs | Diagnostic impossible | Diagnostic settings non configurés | Centraliser dans Log Analytics |
| Coût inattendu | Dépassement budget | Ressources oubliées | Budget, tags, alertes, suppression |
| Droits excessifs | Action non autorisée | Rôle Owner trop large | RBAC minimal et revue d'accès |
| Stockage non protégé | Fuite ou perte de données | Configuration faible | Chiffrement, accès privé, sauvegarde |

### 12.2 Priorisation

- **Priorité haute :** risque de compromission, indisponibilité majeure, coût important imminent.
- **Priorité moyenne :** amélioration nécessaire mais sans urgence immédiate.
- **Priorité basse :** optimisation utile mais non bloquante.

---

## 13. Recommandations SI pour une DSI

### 13.1 Ce qu'une DSI attend

Une DSI ne souhaite pas seulement une liste de services Azure. Elle attend une décision argumentée, lisible et priorisée. La recommandation doit faire le lien entre technique, risque, coût et valeur métier.

### 13.2 Structure recommandée d'une note

1. **Contexte :** rappel de l'environnement et des objectifs.
2. **Constats :** principaux points observés.
3. **Risques :** risques techniques, financiers et sécurité.
4. **Recommandations :** actions proposées, priorité et justification.
5. **Plan d'action :** court terme, moyen terme, long terme.
6. **Indicateurs de suivi :** métriques permettant de vérifier l'amélioration.

### 13.3 Exemple de recommandations attendues

| Domaine | Recommandation | Priorité | Impact attendu |
|---|---|---|---|
| Monitoring | Centraliser logs et métriques dans un workspace commun | Haute | Diagnostic plus rapide |
| FinOps | Rendre les tags Environment et Owner obligatoires | Haute | Attribution des coûts |
| Sécurité | Restreindre les ports d'administration | Haute | Réduction surface d'attaque |
| Gouvernance | Créer des budgets par environnement | Moyenne | Maîtrise financière |
| Audit | Exporter Activity Log vers Log Analytics | Moyenne | Traçabilité des changements |

---

## 14. Architecture cible du TP4

Le TP4 s'appuie sur une architecture simple mais représentative : réseau virtuel, VM, stockage, base de données ou services managés, supervision, coûts et sécurité.

```
Utilisateurs → Application Azure → Données
                    │
       ┌────────────┼────────────┐
  Azure Monitor  Cost Management  Defender / RBAC
```

---

## 15. Méthodologie d'analyse pendant le TP

### 15.1 Démarche recommandée

1. Recenser les ressources et vérifier leur périmètre.
2. Identifier les ressources critiques.
3. Associer chaque ressource à un propriétaire et à un environnement.
4. Définir les indicateurs à surveiller.
5. Mettre en place les alertes pertinentes.
6. Examiner les coûts et anomalies.
7. Analyser la sécurité et les droits.
8. Rédiger les recommandations priorisées.

### 15.2 Questions de contrôle

- Les ressources critiques sont-elles surveillées ?
- Les alertes sont-elles actionnables ?
- Les coûts sont-ils rattachés à un propriétaire ?
- Les droits sont-ils minimaux ?
- Les ports exposés sont-ils justifiés ?
- Les journaux sont-ils conservés assez longtemps ?
- Existe-t-il un plan d'action clair avant production ?

---

## 16. Mini-cas de mise en situation

**Cas 1 — Dépense inattendue.** La facture Azure du mois augmente de 45 %. L'équipe ne sait pas quelle ressource explique cette hausse. Les tags sont incomplets. Aucune alerte budgétaire n'a été configurée. *Quels contrôles auraient dû être mis en place ? Quelles données faut-il rechercher ? Quelles recommandations formuler ?*

**Cas 2 — Incident applicatif.** Les utilisateurs signalent des lenteurs. Les VM semblent actives, mais aucun log applicatif n'est centralisé. Les métriques CPU montrent des pics réguliers. *Quels indicateurs consulter ? Quelles hypothèses formuler ? Quelles alertes créer pour éviter une détection tardive ?*

**Cas 3 — Risque de sécurité.** Un audit révèle qu'un port d'administration est ouvert à Internet. Plusieurs utilisateurs disposent du rôle Owner sur la subscription. *Quels sont les risques ? Quelles corrections appliquer ? Comment prioriser les actions ?*

---

## 17. Questions de vérification

1. Quelle est la différence entre monitoring et observabilité ?
2. Pourquoi une alerte doit-elle être actionnable ?
3. Quel est le rôle d'un Log Analytics Workspace ?
4. Quelle différence entre métriques et logs ?
5. Pourquoi les tags sont-ils essentiels en FinOps ?
6. Qu'est-ce qu'un budget Azure permet de piloter ?
7. Pourquoi le rôle Owner doit-il être limité ?
8. À quoi sert l'Activity Log ?
9. Quels sont les risques d'un port SSH ou RDP ouvert à Internet ?
10. Qu'est-ce qu'une recommandation SI bien formulée ?

---

## 18. Synthèse générale

Le TP4 marque le passage d'une logique de construction à une logique d'exploitation. Une infrastructure cloud ne peut pas être considérée comme prête pour la production si elle n'est pas surveillée, auditée, gouvernée et optimisée.

> **À retenir.** Une plateforme Azure mature repose sur quatre piliers opérationnels : observabilité, FinOps, sécurité et gouvernance. Ces piliers permettent de transformer une architecture technique en système d'information exploitable par une organisation.

---

## 19. Glossaire

| Terme | Définition |
|---|---|
| Azure Monitor | Service de supervision pour collecter et analyser métriques, logs et alertes. |
| Log Analytics Workspace | Espace centralisé pour stocker et interroger des logs Azure. |
| Activity Log | Journal des opérations de gestion réalisées sur les ressources Azure. |
| FinOps | Discipline combinant finance, technologie et opérations pour piloter les coûts cloud. |
| Budget | Seuil financier permettant de suivre une consommation. |
| RBAC | Role-Based Access Control, modèle d'attribution des droits dans Azure. |
| NSG | Network Security Group, filtrage réseau entrant et sortant. |
| Defender for Cloud | Service de gestion de posture et protection des workloads cloud. |
| Secure Score | Indicateur synthétique de posture sécurité. |
| Azure Policy | Service permettant d'auditer ou d'imposer des règles de gouvernance. |

---

## 20. Ressources officielles

- [Microsoft Learn — Azure Monitor](https://learn.microsoft.com/azure/azure-monitor)
- [Microsoft Learn — Cost Management](https://learn.microsoft.com/azure/cost-management-billing/costs)
- [Microsoft Learn — Microsoft Defender for Cloud](https://learn.microsoft.com/azure/defender-for-cloud)
- [Microsoft Learn — Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected)
- [Microsoft Learn — FinOps](https://learn.microsoft.com/cloud-computing/finops)
