# Captures d'écran à faire pour le rendu — ShopEasy

> Portail : https://portal.azure.com — Resource Group **`rg-shopeasy-dev`** — Région **Sweden Central**.
> Astuce : ouvre le RG, la plupart des captures partent de là (vue d'ensemble + chaque ressource).

| # Atelier | Capture(s) attendue(s) | Où, dans le portail | Ce qui doit être visible |
|---|---|---|---|
| **4 — Resource Group** | Le Resource Group | `rg-shopeasy-dev` → *Vue d'ensemble* | Nom, région **Sweden Central**, et l'onglet **Étiquettes (Tags)** : `projet=shopeasy`, `environnement=dev`, `module=cloud`, `proprietaire=ofe26` |
| **5 — Réseau** | VNet + subnets | `vnet-shopeasy-dev` → *Sous-réseaux* | Espace `10.10.0.0/16` et les 3 subnets : `snet-web` 10.10.1.0/24, `snet-data` 10.10.2.0/24, `snet-admin` 10.10.3.0/24 |
| **6 — NSG** | Les 2 NSG + leurs règles | `nsg-web` → *Règles de sécurité de trafic entrant* ; idem `nsg-data` | nsg-web : 80 Internet, 443 Internet, 22 depuis `92.184.109.244/32`. nsg-data : 1433 depuis `10.10.1.0/24` |
| **7 — VM** | (a) les 2 VM, (b) la page web, (c) la vérif | (a) RG filtré sur *Virtual machine* ; (b) navigateur ; (c) la commande | (a) `vm-web-01` et `vm-web-02` en **Running** ; (b) `http://4.223.122.245` → « ShopEasy - VM Web 01 » **et** `http://74.241.247.84` → « ShopEasy - VM Web 02 » ; (c) `vm-web-XX` → *Exécuter une commande / run-command* montrant `systemctl is-active nginx` = `active` |
| **8 — Load Balancer** | (a) le LB + backend pool, (b) la sonde, (c) test navigateur | `lb-shopeasy` → *Pools de back-end* puis *Sondes d'intégrité* | (a) backend pool `bepool-web` avec **2 cibles** (les 2 VM) ; (b) sonde `probe-http` HTTP:80 chemin `/` ; (c) navigateur sur `http://4.223.78.18` affichant une page ShopEasy |
| **9 — Storage** | (a) le compte, (b) les conteneurs, (c) le téléversement | `stshopeasyofe26` → *Configuration* ; puis *Conteneurs* | (a) **Accès public blob = Désactivé**, **TLS 1.2**, HTTPS only ; (b) conteneurs `factures`, `clients`, `archives` ; (c) dans `factures`, le blob `facture-001.txt` |
| **10 — Azure SQL** | La base créée | `sqldb-shopeasy` (base) → *Vue d'ensemble* | Serveur `sql-shopeasy-ofe26`, base **Online**, niveau **Serverless GP_S_Gen5_1** |
| **11 — Monitor** | (a) métriques VM, (b) l'alerte | (a) `vm-web-01` → *Métriques* (choisir « Percentage CPU ») ; (b) *Surveillance → Alertes → Règles d'alerte* | (a) un graphe de CPU ; (b) la règle `alert-cpu-vm-web-01` (seuil > 80 %, fenêtre 5 min) |
| **12 — Coûts** *(optionnel)* | Estimation | https://azure.com/e/ (Pricing Calculator) **ou** *Cost Management* | Estimation des 2 VM + LB + Storage + SQL (≈ ce qui est dans le tableau de coûts) |
| **Nettoyage** *(optionnel)* | Preuve de suppression | `rg-shopeasy-dev` → *Supprimer* | Capture de la confirmation de suppression (à faire **en tout dernier**) |

## Captures indispensables (le strict minimum noté)
Ateliers **4, 5, 6, 7, 8, 9, 10, 11** → soit **~12 captures** en comptant les sous-éléments (2 pages web, backend pool + sonde, etc.).

## Pas de capture (livrables = documents déjà rédigés)
- Atelier 1 (tableau d'analyse), 2 (besoins/services), 3 (schéma — à **exporter** depuis draw.io en PDF/PNG, pas une capture portail), 13 (incidents), 14 (risques), 15 (note DSI).
Tout cela est déjà dans `TP1_ShopEasy_Livrables_complet.pdf`.

## Rappels valeurs réelles (pour légender tes captures)
- Région : **Sweden Central** · VM : **Standard_B2ts_v2** (B1s/France Central refusés par la policy Students)
- IP LB : `4.223.78.18` · VM01 : `4.223.122.245` · VM02 : `74.241.247.84`
- Storage : `stshopeasyofe26` · SQL : `sql-shopeasy-ofe26.database.windows.net`
