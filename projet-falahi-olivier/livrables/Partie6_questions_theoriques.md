# Partie 6. Questions théoriques

Les réponses sont courtes et justifiées, et contextualisées au cas NovaRetail lorsque cela a du sens.

## Questions cloud, Azure et exploitation

1. Différence entre IaaS, PaaS et SaaS.
Les trois modèles décrivent le niveau de service consommé. En IaaS, le fournisseur livre l'infrastructure brute et le client gère encore le système et l'application, par exemple Azure Virtual Machines. En PaaS, le fournisseur gère la plateforme et le client se concentre sur le code et les données, par exemple Azure App Service ou Azure Database for MySQL. En SaaS, le logiciel est consommé directement comme un service, par exemple Microsoft 365.

2. Pourquoi préférer une base managée plutôt qu'une base installée sur une machine dans ce cas.
Une base managée comme Azure Database for MySQL délègue à Azure les sauvegardes, les correctifs, la supervision et les options de haute disponibilité, ce qui réduit la charge d'exploitation et le risque humain. Pour NovaRetail, dont l'équipe est réduite et dont la base est critique, cette délégation fiabilise le service et remplace les sauvegardes manuelles et irrégulières de l'existant.

3. Rôle d'un Virtual Network dans Azure.
Un Virtual Network est le réseau privé logique d'Azure. Il définit une plage d'adresses privées, héberge les ressources comme les machines, et permet de les segmenter en subnets et de contrôler les flux, ce qui isole l'application et applique une défense en profondeur.

4. Différence entre un Network Security Group et une règle RBAC.
Un Network Security Group filtre le trafic réseau entrant et sortant selon des ports, des protocoles et des adresses. Une règle RBAC accorde à des identités des droits d'action sur des ressources Azure. Le premier protège la couche réseau, le second protège la couche de gestion et les autorisations, et les deux contrôles sont complémentaires.

5. Pourquoi l'Infrastructure as Code réduit les risques d'exploitation.
L'Infrastructure as Code décrit l'infrastructure en code versionné, ce qui la rend reproductible, relisible et traçable. Elle réduit les risques d'exploitation parce qu'elle supprime les manipulations manuelles non documentées, garantit que les environnements sont identiques, permet de prévisualiser les changements avant de les appliquer, et facilite une destruction propre.

6. Que contient le state Terraform et pourquoi il doit être protégé.
Le state contient la correspondance entre les ressources déclarées dans le code et les ressources réellement créées, avec leurs identifiants et parfois des valeurs sensibles. Il doit être protégé parce que sa perte fait perdre le suivi des ressources, parce qu'il peut contenir des secrets, et parce qu'un accès partagé sans verrouillage provoque des conflits. La bonne pratique est un backend distant sécurisé.

7. Différence entre monitoring, logs et alertes.
Le monitoring collecte et suit des indicateurs pour vérifier que le système fonctionne. Les logs sont des événements détaillés qui aident à comprendre pourquoi un comportement se produit. Les alertes sont des règles qui préviennent lorsqu'un seuil ou une condition est atteint. Le monitoring montre l'état, les logs expliquent, et les alertes déclenchent l'action.

8. Trois métriques utiles pour piloter une application web.
On surveille le taux de disponibilité ou le taux d'erreurs HTTP, le temps de réponse ou la latence, et l'utilisation du processeur des machines. On peut y ajouter le nombre de requêtes pour suivre la charge.

9. Pourquoi les tags sont essentiels pour le FinOps.
Les tags rattachent chaque ressource à une application, un environnement, un propriétaire et un centre de coût. Ils sont essentiels au FinOps parce qu'ils permettent de ventiler les coûts, de poser des budgets précis, d'identifier les ressources sans propriétaire et de repérer les dépenses inutiles.

10. Trois mesures de sécurité prioritaires avant une mise en production.
La première mesure consiste à restreindre les accès d'administration, par exemple fermer le SSH au monde entier et le limiter à une adresse ou à un bastion. La deuxième consiste à protéger les secrets dans un coffre plutôt que dans le code. La troisième consiste à appliquer le principe du moindre privilège sur les rôles. On y ajoute le chiffrement des flux et la suppression de toute exposition publique de la base et du stockage.

## Questions courtes, traçabilité blockchain

11. Objectif principal d'une blockchain dans un système d'information.
L'objectif est de fournir une preuve partagée, horodatée et difficile à falsifier d'un événement ou d'une donnée, lorsque plusieurs acteurs doivent se fier à un historique commun sans dépendre d'une autorité unique.

12. Composant qui permet de détecter qu'une donnée a été modifiée.
C'est le hash, c'est-à-dire une empreinte cryptographique du contenu dont la valeur change dès que la donnée est modifiée.

13. Pourquoi dit-on qu'une blockchain est append-only.
Parce qu'on y ajoute de nouvelles transactions sans réécrire l'historique existant, ce qui construit une piste d'audit où une correction se fait par ajout plutôt que par suppression.

14. À quel type de contexte d'entreprise Hyperledger Fabric est-il surtout adapté.
Il est adapté à un contexte où les participants sont connus et identifiés, par exemple un consortium, une chaîne d'approvisionnement, la banque, l'assurance ou l'industrie, avec un besoin de confidentialité et de gouvernance.

15. À quels usages Ethereum est-il principalement adapté.
Il est adapté aux usages où la preuve doit être publique et largement vérifiable, comme les applications décentralisées, les jetons et actifs numériques, et les logiques programmables transparentes.

16. À quel besoin de traçabilité ou d'intégrité Azure Confidential Ledger répond.
Il répond au besoin de disposer d'un registre append-only résistant à la falsification pour des données sensibles, par exemple un journal d'audit inviolable, sans avoir à construire un réseau blockchain complet.

17. Rôle d'un smart contract.
Son rôle est de porter et d'appliquer automatiquement les règles métier qui doivent être partagées et vérifiables, comme créer un actif, vérifier une condition, refuser une opération non conforme ou enregistrer un événement horodaté.

18. Pourquoi stocke-t-on généralement les documents lourds ou sensibles off-chain.
Parce que la blockchain n'est pas faite pour les gros volumes, parce que les données personnelles ne peuvent pas être effacées d'un registre immuable, et parce qu'il suffit d'y inscrire une empreinte pour garantir l'intégrité tout en conservant le document dans un stockage contrôlé.

19. Que peut provoquer la compromission d'une clé privée.
Elle permet de signer des transactions frauduleuses au nom de son propriétaire et peut entraîner une perte de contrôle des actifs ou des opérations, c'est pourquoi elle doit être protégée par un coffre, une rotation et une séparation des rôles.

20. Bonne pratique pour les données personnelles dans une solution de traçabilité blockchain.
La bonne pratique est de ne pas inscrire les données personnelles on-chain et de n'y stocker que leur empreinte, en conservant les données elles-mêmes off-chain dans un stockage sécurisé avec contrôle d'accès, afin de respecter la confidentialité et le droit à l'effacement.
