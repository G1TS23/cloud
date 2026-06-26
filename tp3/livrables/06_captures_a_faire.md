# Captures d'écran du rendu — TP3 Administration Azure

> **Statut : captures réalisées** le 26/06/2026, à partir des sorties réelles des commandes exécutées sur l'environnement `rg-shopeasy-dev` (souscription *Azure for Students*, région `swedencentral`).
> Les 10 images sont dans `tp3/screenshots/` et intégrées automatiquement en **Annexe C** du PDF par `scripts/build_rendu_tp3_pdf.py` (ordre alphabétique).
>
> Les captures sont rendues façon terminal à partir des sorties capturées, via `scripts/render_terminal_png.py`. Le nommage `atelier_NN-...` trace chaque preuve.

## Liste des captures (preuves d'exécution)

| # | Fichier | Atelier | Ce qui est visible |
|---|---|---|---|
| 1 | `atelier_01-account-defaults.png` | 1 | Souscription active (*Azure for Students*), valeurs par défaut `az configure`, groupe de ressources |
| 2 | `atelier_02-resource-list.png` | 2 | Inventaire `az resource list` + décompte par type (`uniq -c`) |
| 3 | `atelier_03-tags.png` | 3 | Tags du RG et d'une VM après `az tag update --operation Merge` |
| 4 | `atelier_04-vm-runcommand.png` | 4 | État des VM, `run-command` Nginx, état après `restart` |
| 5 | `atelier_05-inventory-script.png` | 5 | Exécution de `inventory.sh` (synthèse + avertissement VM running) |
| 6 | `atelier_06-vm-power.png` | 6 | `vm-power.sh` status, deallocate, start + extrait du journal |
| 7 | `atelier_07-storage-blobs.png` | 7 | Accès public blob désactivé + liste des blobs du conteneur `operations` |
| 8 | `atelier_08-monitor-alert.png` | 8 | Métriques disponibles, lecture CPU, alerte CPU créée |
| 9 | `atelier_09-healthcheck.png` | 9 | Exécution de `healthcheck.sh` (8 contrôles) |
| 10 | `atelier_10-python-csv.png` | 10 | Exécution de `inventory.py` + tête du CSV généré |

## Valeurs réelles du déploiement (terraform output du 26/06/2026)

- Région : **swedencentral** · VM : **Standard_B2ts_v2**
- IP Load Balancer : **20.91.233.129** (round-robin web 1/2 vérifié via `curl`)
- IP VM web-1 : **135.225.37.122** · IP VM web-2 : **4.223.122.111**
- Storage Account : **shopeasydevdocsa0rnay** (conteneur `operations` privé, accès public désactivé)
- Resource Group : **rg-shopeasy-dev** (14 ressources)
- Alerte Monitor : **alert-cpu-high-vm-shopeasy-dev-web-1** (CPU > 80 %, fenêtre 5 min)
