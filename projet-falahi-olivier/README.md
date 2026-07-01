# Épreuve finale pratique Cloud Azure

Cette épreuve est individuelle et notée sur vingt points. Elle porte sur le cas de la société NovaRetail, qui exploite une application web de gestion de commandes hébergée sur un serveur unique et qui souhaite migrer vers Microsoft Azure. Le travail consiste à analyser l'existant, à concevoir une architecture cible, à diagnostiquer une architecture défectueuse proposée par un prestataire, à décrire un déploiement reproductible avec Terraform, puis à traiter l'administration, le monitoring, le FinOps, la sécurité et quelques questions théoriques.

> Le rendu doit rester totalement anonyme. Aucun nom ne doit apparaître dans les documents, dans les métadonnées des fichiers PDF, ni dans les noms de fichiers ou de dossiers.

## Livrables attendus

Le dossier compressé final doit contenir au minimum les éléments suivants.

| Livrable | Emplacement | Statut |
|---|---|---|
| Rapport final au format PDF | `livrables/` | à faire |
| Schéma d'architecture cible au format PDF ou PNG | `schema/` | à faire |
| Schéma de l'architecture corrigée de la partie 2 | `schema/` | à faire |
| Projet Terraform | `terraform/` | à faire |
| Captures de validation | `screenshots/` | à faire |
| Réponses aux questions théoriques | `livrables/` | à faire |
| Note de recommandations destinée à la DSI | `livrables/` | à faire |

## Plan de l'épreuve et barème

| Partie | Contenu | Points |
|---|---|---|
| Partie 1 | Analyse de l'existant et architecture cible | 3 |
| Partie 2 | Diagnostic d'une architecture défectueuse | 3 |
| Partie 3 | Déploiement et Infrastructure as Code | 4 |
| Partie 4 | Administration, exploitation et automatisation | 2 |
| Partie 5 | Monitoring, FinOps et sécurité | 5 |
| Partie 6 | Questions théoriques, dont la traçabilité blockchain | 2 |
| Qualité du dossier | Lisibilité, structure, preuves et cohérence | 1 |

## Ce que demande chaque partie

La partie 1 attend un tableau d'analyse des risques de l'existant, un tableau de choix des services Azure avec justification, ainsi qu'un schéma d'architecture cible. Ce schéma doit comprendre un Resource Group, un Virtual Network, deux subnets, des Network Security Groups, deux machines virtuelles Linux, un répartiteur de charge, un Storage Account, une base de données managée, Azure Monitor et un Log Analytics Workspace, avec les flux entrants, sortants et internes.

La partie 2 fournit une architecture volontairement défectueuse. Il faut relever au moins douze anomalies en précisant leur domaine, prioriser les cinq risques les plus critiques avec une mesure corrective pour chacun, proposer une architecture corrigée, puis décrire un plan de vérification qui couvre le réseau, la sécurité et le RBAC, Terraform, le monitoring et le FinOps.

La partie 3 attend une structure de projet Terraform contenant au minimum les fichiers `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars` et un `README.md`. Le code décrit le Resource Group, le réseau, les subnets, un Network Security Group avec des règles HTTP et SSH maîtrisées, deux machines virtuelles Linux, un répartiteur de charge, un Storage Account et une ressource de supervision. Le code emploie des variables et propose au moins trois outputs utiles, accompagnés de preuves de validation.

La partie 4 porte sur un inventaire des ressources, une stratégie de tags pour l'exploitation et le pilotage des coûts, et un script ou pseudo script d'exploitation documenté.

La partie 5 attend un dispositif de monitoring comportant au moins quatre métriques et deux alertes, une analyse FinOps, une revue de sécurité présentée sous forme de matrice de risques, et une note de recommandations destinée à la DSI.

La partie 6 regroupe dix questions de cours sur le cloud et Azure, puis dix questions courtes sur la traçabilité blockchain.

## Contraintes techniques retenues

L'abonnement utilisé est de type Azure for Students. La région retenue est Sweden Central, car la région France Central est refusée par la politique de l'abonnement. Lorsque des machines virtuelles sont déployées, la taille retenue est Standard_B2ts_v2, le gabarit Standard_B1s n'étant pas disponible. Le préfixe de nommage s'appuie sur le nom de l'application et l'environnement, par exemple `rg-novaretail-prod`.

## Organisation du dossier

```
epreuve-finale/
  README.md       cahier de bord de l'épreuve
  sujet/          énoncé officiel
  livrables/      rapport final, tableaux, réponses théoriques et note DSI
  terraform/      projet Infrastructure as Code
  schema/         schémas d'architecture cible et corrigée
  scripts/        script d'exploitation de la question 14
  screenshots/    captures de validation
  notes/          brouillons
```

## Méthode de réponse

Chaque réponse est justifiée selon les critères de coût, de sécurité, de performance, de disponibilité et d'exploitabilité. Une simple liste de services ne suffit pas, car les choix sont reliés au besoin métier de NovaRetail. Le réflexe constant consiste à exposer un constat, puis un choix, puis une justification, ce qui correspond à la grille de l'Azure Well-Architected Framework.

Les fiches de révision et la synthèse globale du module restent disponibles dans le dossier `docs/revision/` du dépôt et servent d'appui méthodologique.
