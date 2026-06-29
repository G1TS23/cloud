# Cours 04 — Quiz de validation Terraform

> **Prérequis :** [Cours 01](01_contexte_shopeasy_tp1_et_tp2.md) à [Cours 03](03_network_tf_ligne_par_ligne.md) (ou [Cours 02](02_terraform_comprendre_sans_le_code.md) minimum).  
> 25 questions pour vérifier votre compréhension du parcours et du projet `tp2/terraform/`.  
> **Conseil :** répondez sans regarder les réponses, puis corrigez-vous.

---

## Partie A — QCM (15 questions)

### Question 1

Quelle est la principale différence entre le TP1 et le TP2 sur ShopEasy ?

- A) Le TP2 déploie une application différente
- B) Le TP1 utilise Terraform, le TP2 utilise le portail Azure
- C) Le TP1 déploie à la main, le TP2 décrit la même infra en code Terraform
- D) Le TP2 ne crée pas de machines virtuelles

<details>
<summary><strong>Réponse : C</strong></summary>

Le TP1 construit l'architecture ShopEasy **manuellement** (portail Azure + script bash). Le TP2 **reprend la même logique** mais la décrit dans des fichiers `.tf` rejouables. L'application reste ShopEasy ; seule la **méthode** change.

</details>

---

### Question 2

Terraform est dit « déclaratif ». Qu'est-ce que ça signifie concrètement ?

- A) On liste chaque commande à exécuter dans l'ordre
- B) On décrit l'état final voulu, Terraform calcule les actions
- C) On ne peut déployer qu'une seule ressource à la fois
- D) On doit toujours écrire du JavaScript

<details>
<summary><strong>Réponse : B</strong></summary>

En **déclaratif**, on écrit « il doit exister 2 VM dans le subnet web ». Terraform compare avec Azure et décide seul s'il faut créer, modifier ou supprimer. En **impératif** (script bash), on écrirait « étape 1 : crée le VNet, étape 2 : crée le subnet… ».

</details>

---

### Question 3

Dans le projet ShopEasy, quel provider Terraform pilote Azure ?

- A) `azuread`
- B) `azurerm`
- C) `aws`
- D) `kubernetes`

<details>
<summary><strong>Réponse : B</strong></summary>

Le provider **`azurerm`** (Azure Resource Manager) traduit le code HCL en appels API Azure. Il est déclaré dans `versions.tf` et configuré dans `providers.tf`. `random` est aussi utilisé, mais uniquement pour générer le suffixe du Storage Account.

</details>

---

### Question 4

Que fait la commande `terraform plan` ?

- A) Crée immédiatement toutes les ressources dans Azure
- B) Supprime l'infrastructure
- C) Prévisualise les changements sans les appliquer
- D) Télécharge les providers

<details>
<summary><strong>Réponse : C</strong></summary>

`plan` est l'**aperçu** : créations (`+`), modifications (`~`), suppressions (`-`), remplacements (`-/+`). On le lit **avant** `apply` pour éviter les mauvaises surprises (ex. destruction accidentelle d'une VM).

</details>

---

### Question 5

Que signifie le symbole `-/+` dans un `terraform plan` ?

- A) La ressource sera créée pour la première fois
- B) La ressource sera légèrement modifiée sans interruption
- C) La ressource sera détruite puis recréée
- D) Aucun changement

<details>
<summary><strong>Réponse : C</strong></summary>

`-/+` = **remplacement** : Terraform doit détruire la ressource existante et en créer une nouvelle (souvent parce qu'un attribut est « immuable »). Pour une VM, ça peut signifier une **coupure de service**. C'est le symbole le plus alarmant à surveiller en prod.

</details>

---

### Question 6

Dans `resource "azurerm_resource_group" "main"`, que représente `"main"` ?

- A) Le nom affiché dans le portail Azure
- B) Un nom logique interne au code Terraform
- C) La région Azure
- D) Le nom de l'abonnement

<details>
<summary><strong>Réponse : B</strong></summary>

`"main"` est l'**identifiant local** de la ressource dans le code. Le vrai nom Azure est `rg-${local.prefix}` → `rg-shopeasy-dev`. On référence la ressource ailleurs avec `azurerm_resource_group.main.name`.

</details>

---

### Question 7

Pourquoi utilise-t-on `local.prefix` (`shopeasy-dev`) dans les noms de ressources ?

- A) C'est obligatoire pour Azure
- B) Pour avoir des noms cohérents et identifiables sur tout le projet
- C) Pour chiffrer les ressources
- D) Pour éviter d'utiliser des variables

<details>
<summary><strong>Réponse : B</strong></summary>

`locals.tf` calcule `prefix = "${var.project}-${var.environment}"`. Toutes les ressources portent le même préfixe (`rg-shopeasy-dev`, `vnet-shopeasy-dev`, `vm-shopeasy-dev-web-1`…). C'est une **convention de nommage** : lisibilité, gouvernance et repérage des coûts.

</details>

---

### Question 8

Où doit-on renseigner `subscription_id` et `allowed_ssh_cidr` dans le projet ?

- A) Directement dans `network.tf`
- B) Dans `terraform.tfvars` (fichier non versionné)
- C) Dans `terraform.tfstate`
- D) Dans le portail Azure uniquement

<details>
<summary><strong>Réponse : B</strong></summary>

Ce sont des **variables** sensibles ou personnelles. Elles vont dans `terraform.tfvars`, copié depuis `terraform.tfvars.example`. Ce fichier est ignoré par Git (`.gitignore`) pour ne pas exposer l'ID d'abonnement ni votre IP SSH.

</details>

---

### Question 9

Pourquoi le fichier `terraform.tfstate` ne doit-il **pas** être commité dans Git ?

- A) Il est trop volumineux pour GitHub
- B) Il peut contenir des secrets et provoquer des conflits en équipe
- C) Git ne supporte pas les fichiers JSON
- D) Terraform le régénère à chaque `fmt`

<details>
<summary><strong>Réponse : B</strong></summary>

Le **state** fait le lien code ↔ ressources réelles (IDs, parfois mots de passe). Le versionner = risque de fuite + si deux personnes modifient en parallèle, corruption du state. En entreprise, on le stocke dans un **backend distant** (Azure Storage) avec verrouillage.

</details>

---

### Question 10

Combien de machines virtuelles web le projet ShopEasy déploie-t-il ?

- A) 1
- B) 2
- C) 3
- D) Une par subnet

<details>
<summary><strong>Réponse : B</strong></summary>

Dans `compute.tf`, `count = 2` crée **2 VM** identiques (`vm-shopeasy-dev-web-1` et `vm-shopeasy-dev-web-2`). Le Load Balancer répartit le trafic HTTP entre elles.

</details>

---

### Question 11

Quel est le rôle du Load Balancer dans l'architecture ShopEasy ?

- A) Stocker les documents clients
- B) Répartir le trafic HTTP entre les 2 VM web
- C) Remplacer le pare-feu NSG
- D) Héberger la base de données SQL

<details>
<summary><strong>Réponse : B</strong></summary>

Le LB (`loadbalancer.tf`) expose une **IP publique unique** et distribue le port 80 vers le pool de 2 VM. La sonde HTTP (`/`) vérifie que les VM répondent. C'est le **point d'entrée** de l'application pour les utilisateurs Internet.

</details>

---

### Question 12

Que fait le NSG associé au subnet `snet-data` (option A autonomie) ?

- A) Autorise HTTP depuis Internet
- B) Autorise SSH depuis n'importe quelle IP
- C) Autorise SQL (1433) uniquement depuis le subnet web, refuse le reste
- D) N'a aucune règle de sécurité

<details>
<summary><strong>Réponse : C</strong></summary>

`security.tf` définit `nsg-shopeasy-dev-data` : règle `Allow-SQL-From-Web` (source = `10.20.1.0/24`) + `Deny-All-Inbound`. Le subnet data est **privé** : pas d'accès direct depuis Internet, seulement depuis les VM web pour une future base SQL.

</details>

---

### Question 13

Pourquoi le projet utilise `swedencentral` au lieu de `francecentral` ?

- A) C'est plus rapide en France
- B) La policy Azure for Students interdit `francecentral`
- C) Terraform ne supporte pas la France
- D) Le Load Balancer l'exige

<details>
<summary><strong>Réponse : B</strong></summary>

L'abonnement **Azure for Students** bloque certaines régions et gabarits VM. D'où `location = "swedencentral"` et `vm_size = "Standard_B2ts_v2"` dans les variables — le même code s'adapte via `terraform.tfvars` sans tout réécrire.

</details>

---

### Question 14

Qu'est-ce que le **drift** (dérive) ?

- A) Une erreur de syntaxe dans un fichier `.tf`
- B) Un écart entre le code Terraform et l'état réel dans Azure
- C) Le téléchargement automatique des providers
- D) La suppression du state local

<details>
<summary><strong>Réponse : B</strong></summary>

Le drift survient quand quelqu'un modifie l'infra **à la main dans le portail** (ex. ouvre SSH à `0.0.0.0/0`). Au prochain `plan`, Terraform détecte l'écart et propose de **revenir au code**. Règle : tout passe par le code, pas par le portail.

</details>

---

### Question 15

À la fin d'une séance de TP, quelle commande est **obligatoire** pour éviter des coûts inutiles ?

- A) `terraform init`
- B) `terraform fmt`
- C) `terraform destroy`
- D) `terraform validate`

<details>
<summary><strong>Réponse : C</strong></summary>

`destroy` supprime toutes les ressources gérées par Terraform (VM, LB, storage…). C'est du **FinOps** : ne pas laisser tourner une infra de test H24 le week-end. Le README et le script `azure-account.sh guard` rappellent cette obligation.

</details>

---

## Partie B — Questions ouvertes (10 questions)

### Question 16

Citez les 7 commandes Terraform du workflow dans l'ordre logique utilisé au TP2.

<details>
<summary><strong>Réponse</strong></summary>

```
init → fmt → validate → plan → apply → output → destroy
```

| Commande | Rôle |
|---|---|
| `init` | Télécharge les providers, prépare le dossier |
| `fmt` | Formate le code HCL |
| `validate` | Vérifie syntaxe et cohérence |
| `plan` | Prévisualise les changements |
| `apply` | Applique réellement dans Azure |
| `output` | Affiche les valeurs utiles (IP LB, etc.) |
| `destroy` | Supprime toute l'infra |

**Explication :** `init` se fait une fois (ou après ajout de provider). `fmt`/`validate`/`plan` sont des contrôles **avant** le déploiement. `destroy` est la phase de **nettoyage** en fin de travail.

</details>

---

### Question 17

Quelle est la différence entre une **variable**, un **local** et un **output** ? Donnez un exemple de chaque dans le projet ShopEasy.

<details>
<summary><strong>Réponse</strong></summary>

| Concept | Rôle | Exemple ShopEasy |
|---|---|---|
| **Variable** | Ce qui **entre** (paramètre configurable) | `var.location` = `"swedencentral"` |
| **Local** | Ce qui est **calculé** dans le projet | `local.prefix` = `"shopeasy-dev"` |
| **Output** | Ce qui est **exposé** après déploiement | `load_balancer_public_ip` = IP du LB |

**Explication :** les variables rendent le code réutilisable (dev/test/prod). Les locals évitent de répéter des calculs (préfixe, tags). Les outputs donnent les infos dont on a besoin après `apply` sans aller chercher dans le portail Azure.

</details>

---

### Question 18

Expliquez ce que fait `azurerm_resource_group.main.name` quand il apparaît dans `network.tf`.

<details>
<summary><strong>Réponse</strong></summary>

C'est une **référence** à la ressource Resource Group déclarée dans `network.tf` avec l'identifiant logique `main`. Terraform lit la valeur réelle (`rg-shopeasy-dev`) et crée un **lien de dépendance** : le VNet ne peut pas être créé avant le Resource Group.

**Explication :** pas besoin de `depends_on` explicite dans la plupart des cas — Terraform construit seul le **graphe de dépendances** à partir de ces références.

</details>

---

### Question 19

Pourquoi le script `azure-account.sh guard` est-il exécuté avant `plan` et `apply` ?

<details>
<summary><strong>Réponse</strong></summary>

C'est un **garde-fou multi-comptes** : il vérifie que la session Azure CLI pointe bien vers le compte de **FORMATION** (et non un abonnement personnel ou d'entreprise). Combiné à `subscription_id` épinglé dans `providers.tf`, cela évite de déployer accidentellement sur le mauvais abonnement.

**Explication :** en conditions réelles, déployer sur le mauvais compte peut coûter cher, violer des policies ou supprimer des ressources de prod. Le garde-fou transforme une erreur humaine en **blocage explicite**.

</details>

---

### Question 20

Que fait le fichier `templates/cloud-init.yml` au démarrage des VM ?

<details>
<summary><strong>Réponse</strong></summary>

C'est un script d'initialisation injecté via `custom_data` dans `compute.tf`. Au premier boot de chaque VM, il :

1. met à jour les paquets ;
2. installe **Nginx** ;
3. crée une page HTML « ShopEasy - serveur web 1 » (ou 2) ;
4. démarre Nginx.

**Explication :** sans cloud-init, les VM seraient des Ubuntu vides. Terraform crée la machine **et** configure le serveur web automatiquement — pas besoin de SSH manuel pour installer Nginx.

</details>

---

### Question 21

Pourquoi le Storage Account utilise-t-il un `random_string` dans son nom ?

<details>
<summary><strong>Réponse</strong></summary>

Les noms de Storage Account Azure doivent être **globalement uniques** dans le monde (3–24 caractères, minuscules/chiffres). Le suffixe aléatoire (`random_string.suffix`) évite les collisions si un autre étudiant choisit le même préfixe `shopeasydocs`.

**Explication :** sans random, un second `apply` ou un autre binôme pourrait échouer avec « nom déjà pris ». Le provider `random` génère une valeur stable stockée dans le state.

</details>

---

### Question 22

Quelle IP publique doit-on utiliser pour tester l'application web ShopEasy après un `terraform apply` ? Celle du Load Balancer ou celle d'une VM directement ? Pourquoi ?

<details>
<summary><strong>Réponse</strong></summary>

On utilise l'IP du **Load Balancer** (`terraform output load_balancer_public_ip`).

**Explication :** le LB est le point d'entrée officiel : il répartit le trafic entre les 2 VM et bascule si une VM tombe (sonde HTTP). Tester une VM directement (`web_vm_public_ips`) contourne le LB et ne valide pas le comportement réel de l'architecture.

</details>

---

### Question 23

Que se passe-t-il si vous modifiez manuellement une règle NSG dans le portail Azure, puis lancez `terraform plan` ?

<details>
<summary><strong>Réponse</strong></summary>

Terraform **détecte le drift** : le plan affichera une modification (`~`) sur la ressource NSG pour **revenir à l'état décrit dans `security.tf`**.

**Explication :** le code est la source de vérité. Une modif manuelle n'est ni tracée dans Git ni reproductible. C'est pourquoi la règle du TP est : **aucune modification dans le portail** — tout passe par une pull request sur les fichiers `.tf`.

</details>

---

### Question 24

Nommez les 4 fichiers `.tf` du projet et la responsabilité de chacun.

<details>
<summary><strong>Réponse</strong></summary>

| Fichier | Responsabilité |
|---|---|
| `network.tf` | Resource Group, VNet, subnets (`snet-web`, `snet-data`) |
| `security.tf` | NSG web + data, associations aux subnets |
| `compute.tf` | IPs publiques, NIC, 2 VM Linux Ubuntu + cloud-init |
| `loadbalancer.tf` | Load Balancer, pool backend, sonde HTTP, règle port 80 |
| `storage.tf` | Storage Account + conteneur `documents` (privé) |

(Bonus : `variables.tf`, `locals.tf`, `outputs.tf`, `providers.tf`, `versions.tf` pour la configuration du projet.)

**Explication :** découper par **responsabilité** rend le projet lisible. Un nouveau arrivant lit `network.tf` pour le réseau, `compute.tf` pour les serveurs, sans parcourir un fichier géant.

</details>

---

### Question 25

En 2–3 phrases : pourquoi l'Infrastructure as Code (IaC) est-elle préférable au déploiement manuel pour ShopEasy ?

<details>
<summary><strong>Réponse modèle</strong></summary>

L'IaC décrit l'infrastructure ShopEasy dans des fichiers texte versionnés (Git), ce qui la rend **reproductible** : le même code recrée un environnement identique en quelques minutes. Chaque changement est **traçable** et revu avant application (`plan` puis `apply`). On évite la dérive entre environnements et on peut **détruire** proprement l'infra en fin de séance (`destroy`), ce qui maîtrise les coûts.

**Explication :** c'est le message central du TP2. Le portail Azure est utile pour découvrir, mais ingérable à l'échelle (dev/test/prod, équipes, audit). Terraform transforme l'infra en **actif logiciel**.

</details>

---

## Barème indicatif

| Score | Niveau |
|---|---|
| 23–25 / 25 | Très bon — vous maîtrisez les bases |
| 18–22 / 25 | Bon — relire variables/state/drift |
| 13–17 / 25 | En cours — reprendre le [Cours 02](02_terraform_comprendre_sans_le_code.md) sections 4–7 |
| < 13 / 25 | À retravailler — relire le cours puis refaire le quiz |

---

## Pour aller plus loin

- Index documentation : [`docs/README.md`](../README.md)
- Index du parcours : [`docs/cours/README.md`](README.md)
- Quiz officiel du TP (20 questions) : [`tp2/livrables/02_quiz_reponses.md`](../../tp2/livrables/02_quiz_reponses.md)
- Fiche de révision condensée : [`tp2/sujet/Fiche_revision_Terraform.md`](../../tp2/sujet/Fiche_revision_Terraform.md)
- Relancer un déploiement réel : [`README.md`](../../README.md) section TP2
