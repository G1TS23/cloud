# TP3 — Administration Cloud et Automatisation Azure — Compte rendu des ateliers

> Cas fil rouge : exploitation de l'environnement **ShopEasy** sur Azure, déployé au TP2 avec Terraform.
> Resource Group : `rg-shopeasy-dev` — Région : `swedencentral` — Souscription : *Azure for Students*.
>
> **Note de contexte.** Le sujet propose des noms génériques (`vm-shopeasy-web-01`, `francecentral`, `stshopeasydev001`). Ils sont **adaptés** aux ressources réellement déployées par Terraform au TP2 et conservés dans [`variables.sh`](../variables.sh). La région `francecentral` étant interdite par la policy *Azure for Students*, l'environnement vit à `swedencentral`.
>
> **État de l'environnement.** Infrastructure **redéployée et validée le 26/06/2026** (`terraform apply` → 24 ressources). Valeurs réelles : Load Balancer `20.91.233.129`, VM web-1 `135.225.37.122`, VM web-2 `4.223.122.111`, Storage `shopeasydevdocsa0rnay`. Toutes les commandes ci-dessous ont été exécutées réellement sur cet environnement ; les preuves sont regroupées en **Annexe C** du PDF et listées dans [`06_captures_a_faire.md`](06_captures_a_faire.md).

## Variables utilisées

```bash
export RG="rg-shopeasy-dev"
export LOCATION="swedencentral"
export VM1="vm-shopeasy-dev-web-1"
export VM2="vm-shopeasy-dev-web-2"
export STORAGE="shopeasydevdocsa0rnay"
export CONTAINER="operations"
export AZURE_SUBSCRIPTION_ID="cdca6d99-645a-4251-85e1-f078d1bd66ff"
```

Le fichier complet et commenté est livré dans [`tp3/variables.sh`](../variables.sh) et se charge via `source tp3/variables.sh`.

---

## Atelier 1 — Prise en main d'Azure CLI

**Objectif.** Vérifier l'accès Azure, identifier la souscription active et se positionner sur le bon groupe de ressources.

Commandes exécutées :

```bash
az account show --output table
az configure --defaults group=$RG location=$LOCATION
az configure --list-defaults --output table
az group show --name $RG --query "{Nom:name,Region:location,Etat:properties.provisioningState}" --output table
```

Résultats observés :

```
EnvironmentName    IsDefault    Name                State    TenantDefaultDomain
-----------------  -----------  ------------------  -------  -------------------
AzureCloud         True         Azure for Students  Enabled  efrei.net

Name      Source                    Value
--------  ------------------------  ---------------
group     /home/paul/.azure/config  rg-shopeasy-dev
location  /home/paul/.azure/config  swedencentral

Nom              Region         Etat
---------------  -------------  ---------
rg-shopeasy-dev  swedencentral  Succeeded
```

**Analyse.** La souscription active est bien le compte de formation (*Azure for Students*, tenant `efrei.net`) — vérifié au préalable par le garde-fou [`scripts/azure-account.sh guard`](../../scripts/azure-account.sh) qui interdit tout déploiement sur un abonnement d'entreprise. La configuration de valeurs par défaut (`group`, `location`) évite de répéter `--resource-group` et `--location` sur chaque commande, ce qui réduit le risque d'erreur de saisie en exploitation.

**Livrable.** Capture `atelier_01-account-defaults.png`.

---

## Atelier 2 — Inventorier les ressources Azure

**Objectif.** Produire un inventaire lisible et reproductible des ressources ShopEasy, sans passer par le portail.

Commandes exécutées :

```bash
az resource list --resource-group $RG --query "[].{Nom:name,Type:type,Region:location}" --output table
az resource list --resource-group $RG --output json > tp3/exports/resources.json
az resource list --resource-group $RG --query "[].{Nom:name,Type:type,Region:location}" --output tsv > tp3/exports/resources.tsv
az resource list --resource-group $RG --query "[].type" --output tsv | sort | uniq -c
```

Décompte par type de ressource (14 ressources au total) :

| Nb | Type Azure |
|---|---|
| 2 | `Microsoft.Compute/disks` |
| 2 | `Microsoft.Compute/virtualMachines` |
| 1 | `Microsoft.Network/loadBalancers` |
| 2 | `Microsoft.Network/networkInterfaces` |
| 2 | `Microsoft.Network/networkSecurityGroups` |
| 3 | `Microsoft.Network/publicIPAddresses` |
| 1 | `Microsoft.Network/virtualNetworks` |
| 1 | `Microsoft.Storage/storageAccounts` |

### Tableau d'inventaire commenté

| Nom ressource | Type Azure | Région | Rôle dans l'architecture |
|---|---|---|---|
| `vnet-shopeasy-dev` | `virtualNetworks` | swedencentral | Réseau privé `10.20.0.0/16` (subnets web + data) |
| `nsg-shopeasy-dev-web` | `networkSecurityGroups` | swedencentral | Pare-feu du subnet web (HTTP 80 + SSH restreint) |
| `nsg-shopeasy-dev-data` | `networkSecurityGroups` | swedencentral | Pare-feu du subnet data (SQL depuis web, Deny-All) |
| `lb-shopeasy-dev-web` | `loadBalancers` | swedencentral | Répartiteur HTTP public (round-robin sur les 2 VM) |
| `pip-shopeasy-dev-lb` | `publicIPAddresses` | swedencentral | IP publique du Load Balancer (`20.91.233.129`) |
| `pip-shopeasy-dev-web-1/2` | `publicIPAddresses` | swedencentral | IP publiques directes des VM (administration) |
| `nic-shopeasy-dev-web-1/2` | `networkInterfaces` | swedencentral | Cartes réseau des VM (rattachées au backend pool) |
| `vm-shopeasy-dev-web-1/2` | `virtualMachines` | swedencentral | Serveurs web Nginx (`Standard_B2ts_v2`) |
| `vm-...-web-1/2_OsDisk_...` | `disks` | swedencentral | Disques OS managés des VM |
| `shopeasydevdocsa0rnay` | `storageAccounts` | swedencentral | Compte de stockage des documents/rapports |

**Analyse.** L'inventaire est rejouable : les fichiers [`exports/resources.json`](../exports/resources.json) (392 lignes, machine-exploitable) et [`exports/resources.tsv`](../exports/resources.tsv) (réutilisable dans un script Bash via `cut`/`awk`) constituent une photographie datée du périmètre. Le décompte par type permet de détecter immédiatement une dérive (par exemple un disque orphelin ou une IP publique inattendue).

**Livrable.** `exports/resources.json`, `exports/resources.tsv`, capture `atelier_02-resource-list.png`.

---

## Atelier 3 — Normaliser les tags d'exploitation

**Objectif.** Appliquer une stratégie de tags minimale pour faciliter l'exploitation, le suivi des coûts (FinOps) et l'identification des responsabilités.

Commandes exécutées (mode **Merge** pour ne pas écraser les tags déjà posés par Terraform) :

```bash
RG_ID=$(az group show --name $RG --query id -o tsv)
az tag update --resource-id "$RG_ID" --operation Merge \
  --tags Application=shopeasy Environment=dev Owner=formation CostCenter=cloud-lab ManagedBy=cli

VM1_ID=$(az vm show -g $RG -n $VM1 --query id -o tsv)
az tag update --resource-id "$VM1_ID" --operation Merge \
  --tags Application=shopeasy Environment=dev Role=web Owner=formation
```

> **Point d'attention.** La commande `az vm update --set tags...` du sujet renvoie sur cette souscription l'erreur `Operation 'Enabling zone movement' is not supported`. La pose de tags via `az tag update --operation Merge` est plus robuste et **préserve** les tags Terraform (`project`, `environment`, `owner`, `managed_by`, `cost_center`).

Tags du groupe de ressources après application :

```json
{
  "Application": "shopeasy", "CostCenter": "cloud-lab", "ManagedBy": "cli",
  "cost_center": "cloud-training", "environment": "dev",
  "managed_by": "terraform", "owner": "formation", "project": "shopeasy"
}
```

Tags d'une VM après application :

```json
{
  "Application": "shopeasy", "Role": "web",
  "cost_center": "cloud-training", "environment": "dev",
  "managed_by": "terraform", "owner": "formation", "project": "shopeasy"
}
```

**Pourquoi les tags sont utiles (FinOps et gouvernance).** Les tags transforment un parc de ressources opaque en un parc *interrogeable* : la facturation Azure Cost Management peut être ventilée par `Application` ou `CostCenter` pour répondre à « combien coûte ShopEasy ce mois-ci ? » ; le tag `Owner` désigne un responsable joignable en cas d'incident ; `Environment` permet de cibler les actions d'arrêt nocturne sur les seules ressources `dev` ; `ManagedBy` distingue ce qui est piloté par l'IaC de ce qui a été modifié à la main (signal de dérive). Sans tags, ces questions imposent un inventaire manuel coûteux et faillible.

**Livrable.** Captures `atelier_03-tags.png` (sortie CLI des tags RG + VM).

---

## Atelier 4 — Administrer les machines virtuelles

**Objectif.** Réaliser les opérations courantes sur les VM : lister, vérifier l'état, redémarrer, désallouer et exécuter une commande distante.

État synthétique des VM :

```bash
az vm list --resource-group $RG --show-details \
  --query "[].{Nom:name,Etat:powerState,IP:publicIps,Taille:hardwareProfile.vmSize}" \
  --output table
```

```
Nom                    Etat        IP              Taille
---------------------  ----------  --------------  ----------------
vm-shopeasy-dev-web-1  VM running  135.225.37.122  Standard_B2ts_v2
vm-shopeasy-dev-web-2  VM running  4.223.122.111   Standard_B2ts_v2
```

Commande distante (vérification du serveur web sans SSH interactif) :

```bash
az vm run-command invoke --resource-group $RG --name $VM1 --command-id RunShellScript \
  --scripts "hostname && uptime && systemctl is-active nginx && curl -s localhost | grep -oiE 'ShopEasy[^<]*'"
```

```
vm-shopeasy-dev-web-1
 08:09:56 up 4 min,  0 users,  load average: 0.10, 0.15, 0.08
active
ShopEasy - serveur web 1
```

Redémarrage puis vérification de l'état :

```bash
az vm restart --resource-group $RG --name $VM1
az vm get-instance-view -g $RG -n $VM1 \
  --query "instanceView.statuses[?starts_with(code,'PowerState/')].displayStatus" -o tsv
# -> VM running
```

### Tableau des actions VM

| VM | Taille | IP publique | État | Action réalisée | Résultat |
|---|---|---|---|---|---|
| `vm-shopeasy-dev-web-1` | Standard_B2ts_v2 | 135.225.37.122 | VM running | `run-command` (nginx) puis `restart` | Nginx actif, page « serveur web 1 », redémarrage OK |
| `vm-shopeasy-dev-web-2` | Standard_B2ts_v2 | 4.223.122.111 | VM running | `deallocate` puis `start` (via `vm-power.sh`, atelier 6) | Cycle d'arrêt/démarrage validé |

> **Point de vigilance — `stop` vs `deallocate`.** `az vm stop` éteint l'OS mais **continue de facturer le compute** (la VM reste allouée sur un hôte). Pour cesser la facturation compute, il faut `az vm deallocate` (état *Stopped (deallocated)*). C'est le geste FinOps de référence pour un environnement de développement inactif.

**Livrable.** Tableau ci-dessus + captures `atelier_04-vm-runcommand.png`.

---

## Atelier 5 — Script Bash d'inventaire (`inventory.sh`)

**Objectif.** Transformer les commandes manuelles d'inventaire en script réutilisable et enrichi de compteurs.

Le script livré [`scripts/inventory.sh`](../scripts/inventory.sh) reprend la base du sujet et ajoute les améliorations demandées : nombre total de ressources, nombre de VM, nombre de comptes de stockage, nombre de ressources sans tag `Application`, et un avertissement listant les VM encore en cours d'exécution (coût compute facturé). Les exports sont horodatés dans `exports/`.

Exécution réelle :

```
Inventaire Azure - groupe de ressources : rg-shopeasy-dev
Date : 20260626-101400
--------------------------------------------------
Export des ressources (JSON)...
Export des VM (table)...
--------------------------------------------------
Synthese :
  Ressources totales       : 14
  Machines virtuelles      : 2
  Comptes de stockage      : 1
  Ressources sans tag App. : 12
--------------------------------------------------
ATTENTION : VM en cours d'execution (cout compute facture) :
  - vm-shopeasy-dev-web-1
  - vm-shopeasy-dev-web-2
--------------------------------------------------
Export termine dans exports/ :
  - resources-20260626-101400.json
  - vms-20260626-101400.txt
```

**Analyse.** Le script est robuste (`set -euo pipefail`), vérifie l'existence du groupe avant d'agir, et accepte le RG en argument (`./inventory.sh rg-shopeasy-dev`) avec une valeur par défaut. Le compteur « 12 ressources sans tag `Application` » est un signal d'exploitation réel : seuls le groupe et les deux VM ont reçu le tag `Application` à l'atelier 3 ; les ressources réseau et le stockage restent à normaliser (recommandation FinOps).

**Livrable.** Script `inventory.sh`, capture `atelier_05-inventory-script.png`, fichiers `exports/resources-*.json` et `exports/vms-*.txt`.

---

## Atelier 6 — Automatiser l'arrêt/démarrage des VM (`vm-power.sh`)

**Objectif.** Piloter l'alimentation des VM de développement avec un script sûr.

Le script [`scripts/vm-power.sh`](../scripts/vm-power.sh) prend en charge `start | stop | deallocate | status` sur toutes les VM du groupe, avec les mesures de sécurité demandées : confirmation interactive avant `stop`/`deallocate`, refus d'exécution si le nom du groupe contient `prod`, et journalisation horodatée dans [`logs/vm-power.log`](../logs/vm-power.log).

Démonstrations exécutées :

```bash
# 1. Garde-fou anti-production (sortie immédiate, code 2)
$ ./scripts/vm-power.sh rg-shopeasy-prod deallocate
Refus : 'rg-shopeasy-prod' ressemble a un groupe de PRODUCTION. Action interdite par ce script.

# 2. Confirmation refusée (réponse "non") -> aucune action
$ printf 'non\n' | ./scripts/vm-power.sh rg-shopeasy-dev deallocate
Action 'deallocate' annulee par l'utilisateur

# 3. Cycle réel deallocate -> status -> start
$ printf 'oui\n' | ./scripts/vm-power.sh rg-shopeasy-dev deallocate
VM desallouee (cout compute stoppe) : vm-shopeasy-dev-web-1 / -web-2
$ ./scripts/vm-power.sh rg-shopeasy-dev status
Etat : vm-shopeasy-dev-web-1 -> VM deallocated
$ ./scripts/vm-power.sh rg-shopeasy-dev start
VM demarree : vm-shopeasy-dev-web-1 / -web-2
```

Extrait du journal `logs/vm-power.log` :

```
2026-06-26 10:19:54 | rg-shopeasy-dev | deallocate | VM desallouee (cout compute stoppe) : vm-shopeasy-dev-web-1
2026-06-26 10:20:37 | rg-shopeasy-dev | status     | Etat : vm-shopeasy-dev-web-2 -> VM deallocated
2026-06-26 10:21:23 | rg-shopeasy-dev | start      | VM demarree : vm-shopeasy-dev-web-1
```

**Mesures de sécurité ajoutées.** (1) Le filtre `*prod*` empêche un usage accidentel du script sur un environnement de production ; (2) la confirmation `oui/non` protège contre les arrêts involontaires ; (3) le journal trace qui a fait quoi et quand, ce qui est indispensable pour l'audit d'exploitation. `deallocate` est privilégié à `stop` car seul `deallocate` libère le compute facturé.

**Livrable.** Script `vm-power.sh`, journal `logs/vm-power.log`, capture `atelier_06-vm-power.png`.

---

## Atelier 7 — Exploiter un Storage Account

**Objectif.** Disposer d'un espace de stockage privé pour déposer les rapports d'exploitation.

Le compte de stockage `shopeasydevdocsa0rnay` (créé au TP2) est réutilisé. Constat initial : l'accès public au niveau blob était **autorisé** (`allowBlobPublicAccess: True`), car le `storage.tf` du TP2 ne le restreint pas explicitement. C'est précisément un écart d'exploitation que le TP3 corrige.

Commandes exécutées :

```bash
# Durcissement : interdire l'accès public au niveau du compte
az storage account update --name $STORAGE --resource-group $RG --allow-blob-public-access false

# Conteneur privé d'exploitation
az storage container create --account-name $STORAGE --name operations --auth-mode login --public-access off

# Dépôt des exports (auth Entra ID, sans clé de compte)
az storage blob upload --account-name $STORAGE --container-name operations \
  --file exports/resources.tsv --name inventaire/resources.tsv --auth-mode login --overwrite true
```

> **Point RBAC.** Le téléversement via `--auth-mode login` exige un rôle data-plane. Le rôle **`Storage Blob Data Contributor`** a été attribué à l'utilisateur sur le scope du compte de stockage (`az role assignment create`), ce qui évite d'exposer les clés de compte — bonne pratique de sécurité d'exploitation.

Blobs déposés dans `operations` :

```
Nom                                        Taille
-----------------------------------------  --------
inventaire/resources-20260626-101400.json  6793
inventaire/resources.tsv                   1059
rapports/rapport-test.txt                  62
```

**Pourquoi les rapports d'exploitation ne doivent pas être publics.** Un rapport d'exploitation décrit la topologie (noms de VM, IP, types de ressources), l'état de santé et parfois les failles connues. Exposé publiquement, il constitue une cartographie offerte à un attaquant. L'accès doit donc passer par l'authentification Entra ID et le RBAC, jamais par un blob anonyme.

**Livrable.** Capture `atelier_07-storage-blobs.png` (liste des blobs + `allowBlobPublicAccess: False`).

---

## Atelier 8 — Surveiller les métriques avec Azure Monitor

**Objectif.** Lire les métriques d'une VM et créer une alerte sur une ressource critique.

Trois métriques (sur cinq identifiées) pertinentes pour un serveur web :

| Métrique | Unité | Usage |
|---|---|---|
| `Percentage CPU` | Percent | Saturation processeur |
| `Available Memory Bytes` | Bytes | Pression mémoire |
| `Network In Total` | Bytes | Volume de trafic entrant |

Lecture de la métrique CPU (5 derniers points, intervalle 1 min) :

```
Heure                 CPU_moyen
--------------------  -----------
2026-06-26T08:13:00Z  0.87
2026-06-26T08:15:00Z  0.125
2026-06-26T08:17:00Z  0.125
```

Création de l'alerte CPU :

```bash
az monitor metrics alert create \
  --name "alert-cpu-high-$VM1" --resource-group $RG --scopes "$VM_ID" \
  --condition "avg Percentage CPU > 80" --evaluation-frequency 1m --window-size 5m --severity 3
```

```
Nom                                   Severite    Active    Fenetre
------------------------------------  ----------  --------  ---------
alert-cpu-high-vm-shopeasy-dev-web-1  3           True      PT5M
```

**Justification du seuil (80 % sur 5 min).** Un seuil à 80 % moyenné sur une fenêtre de 5 minutes évite les faux positifs liés aux pics ponctuels (démarrage de service, `apt`, cron) tout en détectant une saturation durable avant la dégradation du service. Une fenêtre plus courte rendrait l'alerte bruyante ; un seuil plus haut (95 %) déclencherait trop tard.

**Deux alertes complémentaires proposées pour ShopEasy.** (1) Disponibilité HTTP du Load Balancer (sonde d'intégrité `Health Probe Status` < 100 %) pour détecter une VM sortie du backend ; (2) `Available Memory Bytes` sous un seuil critique (par ex. < 200 Mo) pour anticiper un OOM. **Limite d'une alerte trop sensible :** elle génère de la fatigue d'alerte (les équipes finissent par l'ignorer) ; **trop large :** elle masque la cause réelle et retarde le diagnostic.

**Livrable.** Capture `atelier_08-monitor-alert.png` (métrique CPU + alerte créée).

---

## Atelier 9 — Script de contrôle de santé (`healthcheck.sh`)

**Objectif.** Vérifier rapidement que l'environnement est dans un état acceptable.

Le script [`scripts/healthcheck.sh`](../scripts/healthcheck.sh) enchaîne huit contrôles : existence du groupe, présence d'au moins une VM (avec état), ressources sans tag `Application`, tag `Owner` sur le groupe, alertes Azure Monitor, existence du compte de stockage, existence du conteneur `operations`, et présence d'au moins une règle NSG autorisant HTTP/HTTPS. Il renvoie un code de sortie non nul si un avertissement est détecté (utilisable dans une chaîne CI ou un cron).

Exécution réelle :

```
1. Verification du groupe de ressources        OK  - groupe trouve
2. Verification des VM                          OK  - 2 VM presente(s)
3. Verification des ressources sans tag App.    WARN- 12 ressource(s) sans tag Application
4. Verification du tag Owner sur le groupe      OK  - Owner = formation
5. Verification des alertes Azure Monitor       OK  - 1 alerte
6. Verification du compte de stockage           OK  - shopeasydevdocsa0rnay
7. Verification du conteneur 'operations'       OK  - present
8. Regle NSG autorisant HTTP/HTTPS              OK  - 1 regle
Resultat : avertissement(s) detecte(s)
```

**Contrôles ajoutés (par rapport au modèle du sujet).** Storage Account, conteneur `operations`, compteur de VM, tag `Owner`, et règle NSG HTTP/HTTPS. Le seul `WARN` restant (tag `Application` manquant sur 12 ressources) reflète fidèlement l'état réel et invite à compléter la normalisation des tags — le script joue donc bien son rôle de détecteur d'écart.

**Livrable.** Script `healthcheck.sh`, capture `atelier_09-healthcheck.png`.

---

## Atelier 10 — Automatiser avec Python et le SDK Azure (`inventory.py`)

**Objectif.** Produire un inventaire programmable et un export CSV exploitable dans un tableur.

Le script [`python/inventory.py`](../python/inventory.py) utilise `DefaultAzureCredential` (réutilise la session `az login`), liste les ressources et les VM, et écrit un CSV (`exports/inventory.csv`) avec les colonnes : nom, type, région, tags, rôle supposé. Le CSV est encodé en UTF-8 avec BOM et séparateur `;` pour une ouverture propre dans Excel/LibreOffice.

```
15 ressource(s) exportee(s) dans exports/inventory.csv
```

Extrait du CSV :

```
nom;type;region;tags;role
vnet-shopeasy-dev;Microsoft.Network/virtualNetworks;swedencentral;"...environment=dev;owner=formation...";Réseau privé (VNet)
vm-shopeasy-dev-web-1;Microsoft.Compute/virtualMachines;swedencentral;"...Application=shopeasy;Role=web...";Serveur web (VM Linux Nginx)
```

> **Quand préférer Python à Bash ?** Bash excelle pour enchaîner des commandes `az` simples ; Python devient pertinent dès qu'il faut structurer des données (CSV, JSON imbriqué), gérer des erreurs finement, ou réutiliser la logique dans une application. Le SDK Azure offre des objets typés plutôt que du parsing de texte.

**Livrable.** Script `inventory.py`, `requirements.txt`, fichier `exports/inventory.csv`, capture `atelier_10-python-csv.png`.

---

## Atelier 11 — Analyse FinOps d'exploitation

Traité en détail dans [`03_analyse_finops_securite.md`](03_analyse_finops_securite.md) : tableau des actions FinOps, stratégie d'arrêt/démarrage des VM de développement, politique de tags, seuil d'alerte budgétaire et trois recommandations pour la DSI.

---

## Atelier 12 — Rapport d'exploitation ShopEasy

Produit dans [`04_rapport_exploitation.md`](04_rapport_exploitation.md) : rapport structuré en dix sections avec le tableau de synthèse (Inventaire, Tags, VM, Stockage, Monitoring, Sécurité, FinOps → Conforme / partiel / non conforme).

---
