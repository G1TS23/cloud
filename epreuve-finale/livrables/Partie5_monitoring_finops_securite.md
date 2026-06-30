# Partie 5. Monitoring, FinOps et sécurité

Le dispositif décrit ci-dessous a été déployé réellement sur le groupe `rg-novaretail-prod` au moyen du code Terraform, ce qui garantit qu'il est reproductible. Les preuves sont conservées dans le dossier `screenshots`.

## Question 15. Monitoring et alertes

La supervision s'appuie sur Azure Monitor et sur l'espace de travail Log Analytics `law-novaretail-prod`, qui centralise les métriques et les journaux. Les indicateurs retenus couvrent la disponibilité, la performance, la base de données, le stockage et le coût.

| Élément surveillé | Métrique ou journal | Seuil proposé | Action attendue |
|---|---|---|---|
| Disponibilité applicative | Disponibilité des machines derrière le répartiteur de charge, métrique DipAvailability | Inférieure à 100 pour cent sur cinq minutes | Vérifier les machines et la sonde de santé, alerte de sévérité élevée envoyée à l'équipe. |
| Processeur des machines web | Métrique Percentage CPU des machines | Supérieur à 70 pour cent sur cinq minutes | Analyser la charge, envisager une montée en taille ou en nombre d'instances. |
| Base de données | Processeur et nombre de connexions du serveur MySQL managé | Processeur supérieur à 80 pour cent | Analyser les requêtes et ajuster le niveau de service. |
| Stockage | Transactions et capacité du compte de stockage | Capacité proche de la limite définie | Vérifier l'usage et la politique de cycle de vie. |
| Coût | Budget mensuel consommé sur le groupe de ressources | Quatre vingt pour cent du budget | Analyser les ressources et arrêter celles qui sont inutiles. |

Deux alertes ont été créées et sont actives. La première se déclenche lorsque le processeur de la première machine web dépasse 70 pour cent pendant cinq minutes. La seconde se déclenche lorsque la disponibilité des machines derrière le répartiteur de charge diminue. Les deux alertes sont reliées au groupe d'action `ag-novaretail-prod-ops`, qui notifie l'équipe d'exploitation. À ces deux alertes s'ajoutent les notifications de budget à quatre vingt pour cent et à cent pour cent.

Un tableau de bord d'exploitation regroupe ces indicateurs dans le portail afin de répondre aux questions de pilotage, à savoir si le service fonctionne, si la performance se dégrade et si le coût reste maîtrisé. Les personnes concernées par les alertes sont les membres de l'équipe d'exploitation, joints par le groupe d'action commun.

## Question 16. Analyse FinOps

Les principaux postes de coût de l'architecture sont les deux machines web et leurs disques, le répartiteur de charge avec ses adresses publiques, le serveur MySQL managé, le compte de stockage et l'espace de travail Log Analytics. Les machines et la base représentent la part la plus importante, car elles sont actives en continu.

Les risques de dépassement budgétaire viennent surtout des machines laissées allumées en dehors des périodes d'usage, de la base toujours active, des adresses publiques réservées et du volume de journaux conservés. L'absence de suivi favoriserait l'apparition de ressources oubliées.

Le suivi repose sur les tags déjà appliqués, en particulier application, environment, owner et cost_center, qui permettent de ventiler les coûts par projet et par équipe. Un budget mensuel de cinquante euros a été défini sur le groupe de ressources, avec une notification à quatre vingt pour cent du montant réel et une notification à cent pour cent du montant prévu.

Trois pistes d'optimisation à court terme sont proposées. La première consiste à arrêter et libérer les machines en dehors des périodes d'usage, ce qui supprime le coût de calcul. La deuxième consiste à supprimer les adresses publiques directes des machines pour ne garder que le point d'entrée du répartiteur de charge. La troisième consiste à ajuster la taille des machines et le niveau de la base selon les métriques observées.

Deux pistes d'optimisation à moyen terme complètent l'ensemble. La première consiste à souscrire des réservations ou un plan d'économie lorsque l'usage devient stable et prévisible. La seconde consiste à appliquer une politique de cycle de vie sur le compte de stockage et à limiter la durée de conservation des journaux, afin de réduire les coûts de stockage dans la durée.

## Question 17. Revue de sécurité

La revue ci-dessous reprend la posture réellement déployée et signale les risques résiduels avec leur mesure corrective.

| Risque | Description | Criticité | Mesure corrective |
|---|---|---|---|
| Accès administrateur trop ouvert | L'accès SSH est ouvert sur les machines, mais il est déjà restreint à l'adresse de l'administrateur. | Moyenne | Conserver la restriction par adresse et faire évoluer vers Azure Bastion pour supprimer les adresses publiques. |
| Exposition réseau | Les machines portent des adresses publiques, alors que seule l'entrée du répartiteur de charge a besoin d'être exposée. | Moyenne | Retirer les adresses publiques des machines et passer par un accès privé. |
| Exposition de la base | La base MySQL est managée et privée, accessible uniquement depuis le subnet web sur le port 3306. | Faible | Maintenir l'accès privé et envisager un point de terminaison privé pour renforcer l'isolement. |
| Filtrage réseau | Les groupes de sécurité limitent déjà les flux aux ports utiles. | Faible | Réviser régulièrement les règles et fermer tout port devenu inutile. |
| Protection du stockage | Le compte de stockage est privé, en TLS 1.2, sans accès public aux blobs, avec versioning. | Faible | Ajouter la suppression réversible et une politique de cycle de vie. |
| Gestion des secrets | Le mot de passe de la base est conservé hors du dépôt et n'est pas versionné, mais il reste dans un fichier local. | Moyenne | Stocker les secrets dans Azure Key Vault et utiliser une identité managée. |
| Journaux et audit | L'espace Log Analytics est en place, et le journal d'activité peut y être exporté. | Moyenne | Activer l'export du journal d'activité et des journaux de diagnostic vers l'espace de travail. |
| Chiffrement | Les données sont chiffrées au repos par défaut sur le stockage et la base. | Faible | Vérifier la conformité et documenter les clés. |
| Sauvegarde | La base managée dispose de sauvegardes automatiques, mais aucune restauration n'a été testée. | Moyenne | Définir une politique de sauvegarde et tester une restauration. |
| Droits d'administration | Le contrôle d'accès basé sur les rôles n'a pas encore été restreint au strict nécessaire. | Moyenne | Appliquer le principe du moindre privilège et réserver le rôle Owner à une seule personne. |
| Chiffrement des flux web | Le trafic web est en clair sur le port 80, sans redirection HTTPS. | Moyenne | Mettre en place HTTPS, idéalement via une Application Gateway avec terminaison TLS et pare-feu applicatif. |

## Question 18. Note de recommandations destinée à la DSI

Cette note présente l'architecture retenue pour la migration de l'application de gestion de commandes, les bénéfices attendus, les risques résiduels, les arbitrages, un plan d'action priorisé et les limites de la proposition.

L'architecture retenue répartit la charge web sur deux machines placées derrière un répartiteur de charge, externalise la base de données vers un service MySQL managé et privé, déplace les documents vers un compte de stockage privé, et met en place une supervision centralisée avec des alertes et un budget. L'ensemble est décrit en code Terraform, ce qui rend les déploiements reproductibles.

Les bénéfices attendus sont l'amélioration de la disponibilité grâce à la redondance de la couche web, la réduction de la charge d'exploitation grâce aux services managés, l'amélioration de la sécurité grâce à la segmentation du réseau et au filtrage, et une meilleure maîtrise des coûts grâce aux tags, au budget et aux alertes.

Les risques résiduels concernent surtout l'absence de chiffrement du trafic web, la présence d'adresses publiques sur les machines, la conservation locale du secret de la base et l'absence de test de restauration. Ces points sont identifiés et associés à des mesures correctives.

Les arbitrages reflètent l'équilibre entre le coût, la performance et la sécurité. Le répartiteur de charge simple a été retenu pour cette première migration, alors qu'une Application Gateway avec pare-feu applicatif apporterait une sécurité supérieure pour un coût et une complexité plus élevés. La base managée coûte davantage qu'une base installée sur machine, mais elle réduit fortement le risque et la charge d'exploitation.

Le plan d'action priorisé propose, en priorité haute, de mettre en place le chiffrement HTTPS, de stocker le secret de la base dans un coffre et de restreindre le contrôle d'accès. En priorité moyenne, il propose de retirer les adresses publiques des machines au profit d'un accès privé, d'activer l'export des journaux d'activité et de tester une restauration. En priorité plus basse, il propose d'optimiser les coûts par des réservations et une politique de cycle de vie.

Les limites de la proposition tiennent au cadre de l'exercice. L'architecture reste volontairement simple, mono région, et ne couvre pas encore la haute disponibilité multi zone, la reprise après incident formalisée, ni l'intégration continue du déploiement. Ces évolutions relèveraient d'un projet de production ultérieur, à dimensionner selon la criticité réelle de l'application.
