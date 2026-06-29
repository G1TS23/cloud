# TP4 — Quiz de validation (réponses)

**1. Différence entre monitoring et observabilité ?**
Le monitoring surveille des signaux connus pour répondre à « est-ce que ça fonctionne ? » (seuils, métriques, alertes). L'observabilité va plus loin : elle vise à comprendre « pourquoi ça ne fonctionne pas ? » en corrélant métriques, logs et traces, y compris pour des problèmes non anticipés.

**2. À quoi sert Azure Monitor ?**
C'est le service central de supervision d'Azure : il collecte, stocke et analyse métriques et logs des ressources, déclenche des alertes et alimente dashboards et workbooks pour piloter disponibilité, performance, coût et sécurité.

**3. Quel est le rôle d'un Log Analytics Workspace ?**
C'est l'espace centralisé qui stocke et indexe les logs (et certaines métriques) pour les interroger en KQL, les corréler entre ressources et les conserver selon une rétention définie. Ici `law-shopeasy-dev`, rétention 30 jours.

**4. Pourquoi définir des seuils d'alerte avec prudence ?**
Des seuils trop bas génèrent du bruit et provoquent la fatigue d'alerte (l'équipe ignore les notifications) ; des seuils trop hauts retardent la détection. Le seuil doit refléter un état réellement actionnable.

**5. Qu'est-ce qu'un Action Group ?**
Un objet Azure Monitor qui définit **qui** est notifié et **comment** (email, SMS, webhook, ITSM…) lorsqu'une alerte se déclenche. Ici `ag-shopeasy-ops` notifie l'équipe Ops par email.

**6. Pourquoi les tags sont-ils importants en FinOps ?**
Ils permettent de ventiler et refacturer les coûts par application, environnement, propriétaire ou centre de coût, et d'identifier les ressources optimisables. Sans tags, l'analyse de coût automatique est impossible.

**7. Quel service Azure permet de suivre les coûts ?**
Azure **Cost Management** (avec les budgets et cost alerts), complété par Azure Advisor pour les recommandations d'optimisation.

**8. Pourquoi une ressource sans tag pose-t-elle un problème ?**
Son coût ne peut être rattaché à un usage, une équipe ou un environnement : elle échappe au pilotage financier et devient un candidat fréquent aux dépenses « oubliées ».

**9. Quel risque présente un port SSH ouvert à Internet ?**
Une exposition massive aux attaques par force brute et aux scans automatisés. On restreint SSH à une IP `/32` (cas de ShopEasy : `216.252.179.39/32`) ou on passe par Azure Bastion.

**10. Que signifie le principe du moindre privilège ?**
Accorder uniquement les droits strictement nécessaires à une tâche. Il limite l'impact d'une erreur, d'un compte compromis ou d'un usage abusif. À ShopEasy, le rôle Owner unique au niveau souscription le viole.

**11. Quel journal permet de suivre les modifications réalisées sur les ressources Azure ?**
L'**Activity Log** (journal du plan de gestion ARM), qui trace créations, suppressions, modifications de configuration et changements de droits.

**12. Pourquoi faut-il surveiller les droits RBAC ?**
Parce qu'une élévation de privilèges ou un rôle trop large augmente fortement le risque de compromission ou d'action destructrice ; la revue régulière des attributions est une mesure de sécurité de base.

**13. Citez deux exemples de métriques utiles pour une VM.**
Le pourcentage CPU et le trafic réseau entrant/sortant (autres exemples : disque lu/écrit, disponibilité de la VM).

**14. Citez deux exemples de recommandations de sécurité.**
Restreindre les ports d'administration (SSH/RDP) à des IP autorisées, et appliquer le moindre privilège RBAC (autres : bloquer l'accès public au stockage, activer le chiffrement et la journalisation).

**15. Pourquoi une alerte doit-elle être associée à une procédure d'action ?**
Sans procédure (runbook), l'équipe reçoit un signal sans savoir comment réagir : l'alerte ne se transforme pas en action et perd son intérêt opérationnel.

**16. Différence entre coût constaté et coût prévisionnel ?**
Le coût constaté est la dépense déjà facturée sur la période ; le coût prévisionnel est une projection de fin de période fondée sur la tendance de consommation. Le budget ShopEasy alerte à 80 % du réel et 100 % du prévisionnel.

**17. Pourquoi le chiffrement ne suffit-il pas à lui seul à sécuriser une ressource ?**
Le chiffrement protège les données au repos/en transit, mais ne protège ni contre des droits d'accès trop larges, ni contre une exposition réseau, ni contre une mauvaise configuration. La sécurité est multi-couches.

**18. Quel est l'intérêt d'un tableau de bord pour une DSI ?**
Offrir une vue de pilotage synthétique (disponibilité, charge, coûts, alertes, audit) répondant à des questions de décision, plutôt qu'une accumulation de courbes techniques.

**19. Qu'est-ce qu'une dérive de coût cloud ?**
Une augmentation non maîtrisée de la dépense due à des ressources oubliées, surdimensionnées ou mal taguées, et à l'absence de budget/alerte. Le cloud facturant à la consommation, la dérive peut être rapide.

**20. Donnez trois actions prioritaires avant une mise en production.**
(1) Activer des alertes critiques actionnables avec runbooks ; (2) appliquer le moindre privilège RBAC et restreindre la surface réseau (SSH, IP publiques) ; (3) mettre en place budget, tags obligatoires et un dashboard d'exploitation pour la DSI.
