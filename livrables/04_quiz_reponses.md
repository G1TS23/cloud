# Quiz de validation — Réponses développées (25 questions)

1. **Service pour créer un réseau privé logique ?**
   **Azure Virtual Network (VNet)** — réseau privé isolé dans Azure, comparable au réseau interne d'une entreprise.

2. **Service pour créer une machine virtuelle ?**
   **Azure Virtual Machines** (IaaS).

3. **Différence entre région et zone de disponibilité ?**
   Une **région** est une zone géographique regroupant des datacenters. Une **zone de disponibilité (AZ)** est un ou plusieurs datacenters physiquement séparés *à l'intérieur* d'une région compatible, avec alimentation et réseau indépendants → répartir entre AZ protège contre la panne d'un datacenter.

4. **À quoi sert un Resource Group ?**
   À regrouper logiquement les ressources d'un projet pour les **administrer, taguer, sécuriser (RBAC), suivre les coûts et supprimer** ensemble. Conteneur de cycle de vie.

5. **Pourquoi utiliser plusieurs subnets ?**
   Pour **séparer les rôles** (web, données, admin), appliquer des règles de sécurité différenciées par couche et limiter les mouvements latéraux en cas de compromission.

6. **À quoi sert un Network Security Group ?**
   À **filtrer les flux réseau entrants et sortants** (par port, protocole, source/destination) au niveau d'un subnet ou d'une interface réseau.

7. **Pourquoi ne pas ouvrir SSH à tout Internet ?**
   Pour **réduire la surface d'attaque** : un SSH ouvert subit en permanence des attaques par force brute et des scans. On le restreint à une IP/32 ou on passe par Azure Bastion.

8. **Service remplaçant le stockage local de documents ?**
   **Azure Storage Account** (Blob Storage) — stockage objet durable et externalisé.

9. **Service remplaçant une base SQL installée sur serveur ?**
   **Azure SQL Database** (base relationnelle managée, PaaS).

10. **Pourquoi utiliser un répartiteur de charge ?**
    Pour **distribuer le trafic** sur plusieurs serveurs, **supprimer le point de défaillance unique** et améliorer la disponibilité et la montée en charge.

11. **Différence Azure Load Balancer vs Application Gateway ?**
    Le **Load Balancer** opère au **niveau réseau (couche 4, TCP/UDP)**. L'**Application Gateway** opère au **niveau applicatif (couche 7, HTTP/HTTPS)** avec fonctions avancées : terminaison TLS, routage par chemin/URL, WAF.

12. **Que signifie PaaS ?**
    **Platform as a Service** — le fournisseur gère l'infrastructure et une partie des couches techniques ; le client se concentre sur l'application, les données et la configuration.

13. **Azure SQL Database : IaaS ou PaaS ?**
    **PaaS** — la base est managée (OS, patchs, sauvegardes, HA gérés par Azure).

14. **Pourquoi utiliser Azure Monitor ?**
    Pour **collecter et exploiter les métriques, logs et alertes**, obtenir de la visibilité opérationnelle et détecter les incidents.

15. **Que surveiller sur une VM web ?**
    **CPU, mémoire, disque, disponibilité HTTP, erreurs et activité réseau** (et état du service web).

16. **Que permet Azure Cost Management ?**
    **Suivre, analyser et optimiser les coûts** Azure (budgets, alertes de dépense, ventilation par tags).

17. **Pourquoi taguer les ressources ?**
    Pour identifier **propriétaire, projet, environnement et centre de coût** → gouvernance, analyse FinOps, facturation par projet et automatisation.

18. **Risque d'un compte administrateur partagé ?**
    **Perte de traçabilité** (impossible de savoir qui agit) et **droits trop larges** : un seul secret compromis donne un accès total. Contraire au moindre privilège.

19. **Pourquoi éviter un Storage Account public par défaut ?**
    **Risque d'exposition de données sensibles** (documents clients) à tout Internet. L'accès doit être authentifié (clé, SAS, identité managée).

20. **Mesure réduisant l'impact d'une panne de VM ?**
    Déployer **deux VM (ou plus) derrière un répartiteur de charge**, idéalement dans des zones de disponibilité distinctes.

21. **Pourquoi séparer couche web et couche données ?**
    Pour **réduire les mouvements latéraux**, appliquer le principe de **segmentation/défense en profondeur** et des règles de sécurité spécifiques à chaque couche.

22. **Information devant figurer dans une note de recommandations DSI ?**
    **Architecture, coûts, risques, gains et plan d'action** (avec contexte et limites).

23. **Deux optimisations de coût possibles ?**
    **Arrêt des VM inutilisées** (auto-shutdown) et **choix de tailles adaptées** ; aussi : tags + budgets, base serverless avec auto-pause, réservations si usage stable.

24. **Deux mesures de sécurité prioritaires ?**
    **RBAC (moindre privilège) + MFA** et **NSG restrictifs** ; aussi : chiffrement, logs/alertes, suppression des accès publics inutiles.

25. **Évolution permettant d'automatiser le déploiement ?**
    L'**Infrastructure as Code** (ex. **Terraform** ou **Bicep**), idéalement couplée à un **pipeline CI/CD**.
