# TP2 Terraform — ShopEasy — Compte rendu des ateliers

> Cas fil rouge : industrialisation de l'infrastructure **ShopEasy** sur Azure avec Terraform.
> Région : `swedencentral` — Resource Group : `rg-shopeasy-dev` — VNet : `10.20.0.0/16`.
>
> **Note de contexte.** Comme au TP1, l'abonnement *Azure for Students* impose une policy limitant les régions (`francecentral` interdite) : la région retenue est **`swedencentral`**. Le gabarit `Standard_B1s` étant indisponible (capacité), les VM utilisent **`Standard_B2ts_v2`** (paramétré via la variable `vm_size`).
>
> **État du déploiement.** Le code Terraform est complet et prêt à l'emploi. Les preuves d'exécution (captures terminal, portail, navigateur) sont à produire lors du `terraform apply` sur une souscription de formation, en suivant [`06_captures_a_faire.md`](06_captures_a_faire.md). Les emplacements de captures sont référencés dans la checklist (atelier 9) et l'atelier 11.

---

## Atelier 1 — Initialiser le projet Terraform

Arborescence créée dans `tp2/terraform/` : `versions.tf`, `providers.tf`, `variables.tf`, `locals.tf`, `network.tf`, `security.tf`, `compute.tf`, `loadbalancer.tf`, `storage.tf`, `outputs.tf`, `terraform.tfvars.example`, `.gitignore` et `templates/cloud-init.yml`.

**Point de contrôle — pourquoi `terraform.tfstate` ne doit pas être publié dans un dépôt non sécurisé ?**
Le state est la cartographie complète des ressources gérées par Terraform. Il contient des identifiants de ressources, des métadonnées et parfois des **valeurs sensibles en clair** (chaînes de connexion, clés, mots de passe générés, adresses IP, identifiants de comptes de stockage). Le publier reviendrait à exposer la topologie de l'infrastructure et des secrets exploitables par un attaquant. Il est donc exclu via `.gitignore` (et, en entreprise, stocké dans un backend distant chiffré et soumis au RBAC).

---

## Atelier 2 — Déclarer les providers

`versions.tf` épingle `terraform >= 1.6.0`, `azurerm ~> 4.0` et `random ~> 3.6`. `providers.tf` active le provider `azurerm` avec `features {}`.

**Point de contrôle — résultat attendu de `terraform validate` :**

```
Success! The configuration is valid.
```

> L'épinglage des versions (`required_version`, `version`) garantit la reproductibilité : un collègue ou une pipeline CI/CD utilisera exactement les mêmes versions de providers, évitant les écarts de comportement.

---

## Atelier 3 — Paramétrer le projet

Variables d'entrée déclarées dans `variables.tf` (`project`, `environment`, `location`, `vm_size`, `admin_username`, `ssh_public_key_path`, `allowed_ssh_cidr`, et les préfixes réseau). `locals.tf` calcule `prefix = "shopeasy-dev"` et le bloc `common_tags`.

> Le secret SSH n'est jamais en clair : seul le **chemin** vers la clé publique est passé (`ssh_public_key_path`), et `terraform.tfvars` (qui contient les valeurs concrètes comme `allowed_ssh_cidr`) est ignoré par Git. Un `terraform.tfvars.example` documente les valeurs attendues sans rien exposer.

---

## Atelier 4 — Groupe de ressources et réseau

Créés dans `network.tf` : `rg-shopeasy-dev`, `vnet-shopeasy-dev` (`10.20.0.0/16`), `snet-web` (`10.20.1.0/24`) et — au titre de la mise en autonomie (option A) — `snet-data` (`10.20.2.0/24`).

**Réponses aux questions (8.3) :**

1. **Pourquoi une plage privée pour le VNet ?**
   Les plages `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16` (RFC 1918) ne sont pas routables sur Internet. Elles évitent tout conflit d'adressage avec des réseaux publics, permettent de cloisonner les ressources et imposent de passer par des points d'entrée contrôlés (Load Balancer, IP publiques explicites) pour exposer un service. C'est la base de la segmentation et de la sécurité réseau.

2. **Que faudrait-il ajouter pour isoler une base de données dans un subnet dédié ?**
   Un **subnet dédié** (`snet-data`, déjà ajouté en option A), un **NSG** restrictif n'autorisant que le port de la base (1433 pour SQL) **depuis le subnet web uniquement**, et idéalement un **private endpoint** vers le service managé (Azure SQL) plus une **delegation** de subnet le cas échéant. Aucune IP publique ne doit être attachée à ce subnet.

3. **Pourquoi séparer les fichiers Terraform au lieu de tout mettre dans `main.tf` ?**
   Lisibilité et maintenabilité : chaque fichier regroupe une responsabilité (réseau, sécurité, calcul, stockage). Cela facilite les revues de code, limite les conflits Git en équipe, et permet de retrouver rapidement une ressource. Terraform charge de toute façon **tous** les `.tf` du dossier, le découpage est purement organisationnel.

---

## Atelier 5 — Sécuriser le réseau avec un NSG

`security.tf` crée `nsg-shopeasy-dev-web` (Allow-HTTP 80 depuis Internet, Allow-SSH-Admin 22 depuis `allowed_ssh_cidr`) et son association au subnet web. L'option A ajoute `nsg-shopeasy-dev-data` (1433 depuis le subnet web + Deny-All entrant).

### Analyse de sécurité (9.2)

| Flux | Autorisé ? | Justification | Risque résiduel |
|---|---|---|---|
| Internet → HTTP (80) | Oui | L'application web doit être joignable publiquement via le Load Balancer | Surface exposée au niveau applicatif (DDoS L7, failles web) → atténuée par WAF/Application Gateway en prod |
| SSH depuis votre IP (22, `allowed_ssh_cidr`) | Oui | Administration ponctuelle restreinte à l'IP de l'apprenant | IP dynamique pouvant changer ; usurpation si poste compromis → Bastion en prod |
| SSH depuis Internet complet (0.0.0.0/0) | **Non** | Surface d'attaque massive, brute-force permanent | Aucun (règle volontairement absente) |
| Tout trafic sortant | Oui (par défaut Azure) | Permet `apt`/cloud-init de récupérer Nginx | Exfiltration possible si VM compromise → filtrage egress + firewall en prod |

> **Recul (production).** L'accès SSH direct serait supprimé au profit d'**Azure Bastion**, d'un VPN ou d'un jump server, voire d'une administration sans accès direct (configuration uniquement par IaC + cloud-init).

---

## Atelier 6 — Deux machines virtuelles Linux

`compute.tf` crée, avec `count = 2` : 2 IP publiques `Standard`, 2 NIC dans `snet-web`, 2 VM Ubuntu 22.04 (`vm_size = Standard_B2ts_v2`). Le `cloud-init.yml` installe Nginx et publie une page « ShopEasy - serveur web N » via `templatefile` (variable `server_index`).

**Réponses aux questions (10.4) :**

1. **À quoi sert `count` ?**
   À créer plusieurs instances identiques d'une ressource à partir d'un seul bloc, indexées par `count.index`. Ici, 2 VM (et leurs IP/NIC) sans dupliquer le code. Changer `count` suffit à faire varier le nombre d'instances.

2. **Rôle de `custom_data` ?**
   Passer un script **cloud-init** (encodé en base64) exécuté au premier démarrage de la VM. Il automatise le provisioning (installation et configuration de Nginx, page d'accueil) sans intervention manuelle : la VM est opérationnelle dès le boot.

3. **Pourquoi `Standard_B1s` (ici `B2ts_v2`) est acceptable en formation ?**
   Ce sont des gabarits **burstable** à très faible coût, suffisants pour héberger un Nginx de démonstration sans charge réelle. On privilégie le coût sur la performance pour un environnement de dev/formation. (`B1s` indisponible sur la souscription Students → `B2ts_v2` retenu.)

4. **Pourquoi éviter des IP publiques directes sur les VM en production ?**
   Chaque IP publique est une porte d'entrée supplémentaire à sécuriser et à superviser, augmentant la surface d'attaque. En prod, on n'expose que le Load Balancer / l'Application Gateway, on supprime les IP publiques des VM et on administre via Bastion. (Ici elles ne servent qu'à tester chaque VM individuellement.)

---

## Atelier 7 — Load Balancer

`loadbalancer.tf` crée l'IP publique du LB, le LB `Standard`, le backend pool (associé aux 2 NIC), une probe HTTP `/:80` et une règle TCP 80→80.

**Réponses à l'analyse (11.3) :**

1. **Quel problème résout le Load Balancer ?**
   Le **point de défaillance unique** (SPOF) et l'absence de répartition de charge : il distribue le trafic entrant sur plusieurs VM, améliorant la disponibilité et la capacité à absorber la charge.

2. **Que se passe-t-il si une VM devient indisponible ?**
   La **probe** de santé détecte l'échec (la VM ne répond plus sur `/:80`) et le LB cesse de lui router du trafic. Les requêtes sont automatiquement dirigées vers la VM saine restante : continuité de service (en mode dégradé).

3. **Différence avec Azure Application Gateway ?**
   Le Load Balancer opère en **couche 4** (TCP/UDP). L'Application Gateway opère en **couche 7** (HTTP/HTTPS) : routage par URL/host, terminaison TLS, **WAF** intégré, cookies d'affinité. L'AppGw est préférable pour exposer une application web en production ; le LB suffit pour une répartition réseau simple.

---

## Atelier 8 — Storage Account

`storage.tf` crée un `random_string` (suffixe d'unicité globale), le Storage Account (`Standard` / `LRS` / `TLS1_2` / versioning Blob activé) et un container **privé** `documents`.

**Réponses FinOps et sécurité (12.3) :**

1. **Pourquoi le container doit-il être privé ?**
   Il contient des documents métier (factures, données clients). Un accès public anonyme exposerait des données potentiellement sensibles et constituerait une fuite (et une non-conformité RGPD). L'accès se fait via clés/SAS/identités gérées uniquement.

2. **Pourquoi le versioning peut-il augmenter les coûts ?**
   Chaque modification/suppression d'un blob conserve les **versions antérieures**, qui sont facturées comme du stockage supplémentaire. Sur des objets fréquemment modifiés, le volume cumulé (et donc la facture) croît continuellement.

3. **Quelle règle de cycle de vie proposer ?**
   Une **lifecycle management policy** : transition des anciennes versions vers un tier froid (Cool/Archive) après N jours, puis **suppression** des versions au-delà d'une rétention définie (ex. supprimer les versions > 90 jours). Voir le détail dans `04_autonomie_subnet_prive.md` (section variante lifecycle).

---

## Atelier 9 — Outputs et validation

`outputs.tf` expose `resource_group_name`, `load_balancer_public_ip`, `web_vm_public_ips`, `storage_account_name`.

### Checklist technique (13.1)

> **État :** le code Terraform est complet et prêt. La colonne « Statut » passe à **OK** une fois `terraform apply` exécuté sur une souscription de formation et la capture correspondante déposée dans `tp2/screenshots/` (voir [`06_captures_a_faire.md`](06_captures_a_faire.md)). Tant que le déploiement n'est pas fait, le statut reste **À valider**.

| Contrôle | Statut | Vérification attendue | Capture |
|---|---|---|---|
| Le projet Terraform s'initialise sans erreur | À valider | `terraform init` → *Terraform has been successfully initialized!* | `atelier_02-init.png` |
| `terraform validate` réussit | À valider | *Success! The configuration is valid.* | `atelier_02-validate.png` |
| Le Resource Group est créé | À valider | `terraform output resource_group_name` + portail | `atelier_04-portail-rg.png` |
| Le VNet et les subnets existent | À valider | `terraform state list` (`azurerm_virtual_network.main`, `azurerm_subnet.web`, `.data`) | `atelier_05-vnet-subnets.png` |
| Le NSG limite SSH à votre IP | À valider | Règle `Allow-SSH-Admin` source = `allowed_ssh_cidr` | `atelier_05-nsg-web.png` |
| Deux VM Linux sont créées | À valider | `az vm list -g rg-shopeasy-dev -o table` (2 lignes Running) | `atelier_06-vms.png` |
| Nginx répond sur les VM | À valider | `http://<IP_VM_1>` et `http://<IP_VM_2>` → page ShopEasy | `atelier_06-page-vm1.png` / `-vm2.png` |
| Le Load Balancer répond en HTTP | À valider | `http://<IP_LB>` → page ShopEasy (alternance) | `atelier_09-page-lb.png` |
| Le Storage Account est privé | À valider | Container `documents` access type = `private` | `atelier_08-storage.png` |
| Le versioning Blob est activé | À valider | `blob_properties.versioning_enabled = true` | `atelier_08-storage.png` |
| Les ressources sont taguées | À valider | `common_tags` appliqué sur toutes les ressources taguables | `atelier_04-portail-rg.png` |

> Les captures listées sont à produire en suivant [`06_captures_a_faire.md`](06_captures_a_faire.md) ; elles apparaissent ensuite automatiquement dans l'annexe « Preuves d'exécution » du PDF de rendu.

---

## Atelier 10 — Modifier l'infrastructure

Le tag `cost_center = "cloud-training"` est **déjà présent** dans `common_tags` (`locals.tf`). Pour l'exercice, on illustre l'ajout d'un tag supplémentaire (ex. `reviewed_by`).

**Réponses à l'analyse du plan (14.2) :**

1. **Terraform recrée-t-il toutes les ressources ?**
   Non. Un changement de tag est une modification **in-place** : Terraform affiche `~` (update) et ne touche pas au cycle de vie des ressources.

2. **Quelles ressources sont simplement mises à jour ?**
   Toutes les ressources taguables référençant `local.common_tags` (RG, VNet, NSG, IP, NIC, VM, LB, Storage) : seul leur bloc `tags` est mis à jour.

3. **Pourquoi le plan est-il indispensable ?**
   Il permet de **vérifier l'impact avant application** : distinguer une simple mise à jour (`~`) d'une recréation destructrice (`-/+`), repérer une suppression imprévue, contrôler les coûts et la conformité. C'est le filet de sécurité du workflow déclaratif.

---

## Atelier 11 — Observer une dérive (drift)

Procédure : modifier manuellement un tag sur le RG dans le portail (`manual_change = true`), puis `terraform plan`. Capture attendue : `atelier_11-drift-plan.png` (le `plan` montrant la dérive détectée).

**Réponses à l'analyse (15.2) :**

1. **Terraform détecte-t-il une différence ?**
   Oui. Au `plan`, il rafraîchit le state réel, constate l'écart entre l'infrastructure (tag manuel ajouté) et le code (qui ne le contient pas) et signale un changement.

2. **Quelle action propose-t-il ?**
   De **revenir à l'état déclaré** : il prévoit de **supprimer** le tag `manual_change` ajouté à la main (`~ update in-place`), car le code est la source de vérité.

3. **Pourquoi les modifications manuelles sont-elles dangereuses ?**
   Elles créent une **dérive** entre code et réel : l'infrastructure devient imprévisible, non reproductible, et les changements ne sont ni tracés ni revus. Un `apply` ultérieur peut écraser silencieusement une correction d'urgence faite à la main, ou inversement masquer un changement non documenté.

4. **Quelle règle d'équipe proposer ?**
   **Interdire les modifications manuelles en dehors des urgences** : tout changement passe par une **pull request** modifiant le code Terraform, relue puis appliquée via pipeline. Le portail reste réservé à l'observation/diagnostic. On peut renforcer avec **Azure Policy** et des `plan` planifiés détectant le drift.

---

## Atelier 12 — Préparer un state distant

**Réponses aux questions (16.2) :**

1. **Pourquoi le state distant facilite-t-il le travail en équipe ?**
   Le state est **partagé** et centralisé (un Storage Account Azure), avec **verrouillage** (lock) empêchant deux `apply` simultanés de corrompre le state. Chacun travaille sur la même source de vérité, sans s'échanger un fichier local.

2. **Pourquoi protéger l'accès au Storage Account du state ?**
   Parce que le state contient la cartographie et des **secrets** de l'infrastructure. Un accès non maîtrisé permettrait fuite d'informations ou manipulation. On le protège par **RBAC**, chiffrement au repos, restriction réseau et journalisation.

3. **Pourquoi séparer le state dev / recette / prod ?**
   Pour **isoler les environnements** : un incident, un `destroy` ou une corruption sur le state de dev ne doit jamais impacter la prod. Cela permet aussi des droits d'accès différenciés (moindre privilège par environnement) via des `key` distinctes (`shopeasy/dev/...`, `shopeasy/prod/...`).

---

## Atelier 14 — Nettoyage

```bash
terraform plan -destroy   # verifier ce qui sera detruit
terraform destroy         # supprimer toutes les ressources
```

> Vérifier ensuite dans le portail que `rg-shopeasy-dev` est vide ou supprimé : aucune ressource facturable ne doit subsister.

---

## Synthèse

L'ensemble des ateliers est couvert par le projet Terraform (`tp2/terraform/`). Les analyses FinOps et sécurité approfondies sont dans [`03_analyse_finops_securite.md`](03_analyse_finops_securite.md), l'extension autonomie (option A) dans [`04_autonomie_subnet_prive.md`](04_autonomie_subnet_prive.md), et la note technique de synthèse dans [`05_note_technique.md`](05_note_technique.md).
