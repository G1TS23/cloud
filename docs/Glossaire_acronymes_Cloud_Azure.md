# Glossaire des acronymes — Module Cloud & Azure (TP1 → TP4)

> Tous les sigles et abréviations rencontrés dans le module, par ordre alphabétique, avec une définition succincte. *(Les termes non-acronymes essentiels — Bastion, Defender, Blob… — sont en note en fin de document.)*

| Acronyme | Signification | Définition succincte |
|---|---|---|
| **API** | Application Programming Interface | Interface permettant à des programmes de dialoguer avec un service. |
| **ARM** | Azure Resource Manager | Couche de gestion d'Azure (déploiement/organisation des ressources) ; aussi le format *ARM templates* (JSON). |
| **AZ** | Availability Zone | Datacenter(s) physiquement séparé(s) dans une région, pour la résilience. |
| **AzureRM** | Azure Resource Manager (provider) | Provider Terraform standard pour gérer les ressources Azure. |
| **CapEx / OpEx** | Capital / Operational Expenditure | Dépense d'investissement / dépense de fonctionnement ; le cloud transforme CapEx en OpEx. |
| **CDN** | Content Delivery Network | Réseau de diffusion de contenu mis en cache au plus près des utilisateurs. |
| **CI/CD** | Continuous Integration / Continuous Delivery (ou Deployment) | Chaîne d'intégration et de livraison automatisées du code. |
| **CIDR** | Classless Inter-Domain Routing | Notation des plages d'adresses IP (ex. `10.10.0.0/16`). |
| **CLI** | Command Line Interface | Interface en ligne de commande (ici Azure CLI : `az`). |
| **CMDB** | Configuration Management Database | Base d'inventaire des composants du SI. |
| **CPU** | Central Processing Unit | Processeur ; métrique de charge clé d'une VM. |
| **CSV** | Comma-Separated Values | Format de fichier tabulaire (valeurs séparées par des virgules). |
| **DevOps** | Development + Operations | Culture/pratiques unifiant développement et exploitation. |
| **DNS** | Domain Name System | Système de résolution des noms de domaine en adresses IP. |
| **DSI** | Direction des Systèmes d'Information | Direction responsable du SI (destinataire des notes de reco). |
| **DTU** | Database Transaction Unit | Unité de capacité (compute/mémoire/I-O) d'Azure SQL Database. |
| **FinOps** | Financial Operations | Discipline de pilotage et d'optimisation des coûts cloud. |
| **GRS** | Geo-Redundant Storage | Réplication du stockage entre deux régions géographiques. |
| **HA** | High Availability | Haute disponibilité (continuité du service malgré une panne). |
| **HCL** | HashiCorp Configuration Language | Langage de configuration de Terraform. |
| **HTTP / HTTPS** | HyperText Transfer Protocol (Secure) | Protocole web ; HTTPS = version chiffrée (TLS). Ports 80 / 443. |
| **IaaS** | Infrastructure as a Service | Infrastructure à la demande ; le client gère OS, runtime, app. |
| **IaC** | Infrastructure as Code | Gestion de l'infrastructure par fichiers versionnés (ex. Terraform). |
| **IAM** | Identity and Access Management | Gestion des identités et des accès. |
| **ID** | Identifier | Identifiant unique d'une ressource ou entité. |
| **IP** | Internet Protocol | Adressage réseau ; IPv4 (ex. `92.184.x.x`) / IPv6. |
| **JMESPath** | (JSON query language) | Langage de filtrage/transformation des sorties JSON (option `--query`). |
| **JSON** | JavaScript Object Notation | Format de données structurées, lisible par les machines. |
| **KQL** | Kusto Query Language | Langage de requête des logs dans Log Analytics. |
| **LB** | Load Balancer | Répartiteur de charge (couche 4, TCP/UDP). |
| **LRS** | Locally Redundant Storage | Réplication du stockage au sein d'un seul datacenter. |
| **MFA** | Multi-Factor Authentication | Authentification à plusieurs facteurs. |
| **MG** | Management Group | Conteneur regroupant plusieurs subscriptions pour la gouvernance. |
| **MTTR** | Mean Time To Repair / Resolution | Temps moyen de résolution d'un incident. |
| **NFS** | Network File System | Protocole de partage de fichiers (Unix/Linux) ; supporté par Azure Files. |
| **NIC** | Network Interface Card | Interface réseau (carte) attachée à une VM. |
| **NSG** | Network Security Group | Ensemble de règles de filtrage du trafic réseau entrant/sortant. |
| **OS** | Operating System | Système d'exploitation (ex. Ubuntu). |
| **PaaS** | Platform as a Service | Plateforme managée ; le client se concentre sur le code et les données. |
| **PCA / PRA** | Plan de Continuité / Reprise d'Activité | Dispositifs de continuité et de reprise après incident majeur. |
| **RBAC** | Role-Based Access Control | Contrôle d'accès par rôles attribués sur un scope. |
| **RDP** | Remote Desktop Protocol | Protocole d'accès distant Windows (port 3389). |
| **RG** | Resource Group | Conteneur logique regroupant des ressources liées (cycle de vie commun). |
| **RGPD** | Règlement Général sur la Protection des Données | Réglementation UE sur les données personnelles (GDPR). |
| **RNCP** | Répertoire National des Certifications Professionnelles | Référentiel des certifications (le Mastère vise le niveau 7). |
| **RPO** | Recovery Point Objective | Perte de données maximale tolérée (point de restauration). |
| **RTO** | Recovery Time Objective | Durée maximale d'interruption tolérée avant rétablissement. |
| **RSSI** | Responsable de la Sécurité des SI | Fonction garante de la sécurité du système d'information. |
| **SaaS** | Software as a Service | Logiciel consommé comme un service (ex. Microsoft 365). |
| **SDK** | Software Development Kit | Bibliothèque de développement (ici SDK Azure pour Python). |
| **SI** | Système d'Information | Ensemble des moyens informatiques d'une organisation. |
| **SLA** | Service Level Agreement | Engagement contractuel de niveau de service (avec pénalités). |
| **SLI** | Service Level Indicator | Indicateur **mesuré** de niveau de service (ex. taux de disponibilité). |
| **SLO** | Service Level Objective | Objectif **interne** fixé sur un SLI (ex. 99,5 %/mois). |
| **SMB** | Server Message Block | Protocole de partage de fichiers (Windows) ; supporté par Azure Files. |
| **SPOF** | Single Point Of Failure | Point de défaillance unique (à éliminer pour la disponibilité). |
| **SQL** | Structured Query Language | Langage des bases relationnelles ; aussi Azure SQL Database. |
| **SRE** | Site Reliability Engineering | Ingénierie de la fiabilité des services (exploitation outillée). |
| **SSD** | Solid State Drive | Disque à mémoire flash (ex. disque managé Standard SSD). |
| **SSH** | Secure Shell | Protocole d'administration distante sécurisée Linux (port 22). |
| **TCP / UDP** | Transmission Control / User Datagram Protocol | Protocoles de transport (couche 4) répartis par le Load Balancer. |
| **TLS** | Transport Layer Security | Protocole de chiffrement des communications (ex. TLS 1.2). |
| **TSV** | Tab-Separated Values | Sortie tabulée (`-o tsv`), pratique pour les variables Bash. |
| **UDP** | User Datagram Protocol | Protocole de transport sans connexion (couche 4). |
| **vCore** | virtual Core | Cœur de calcul virtuel ; modèle de capacité d'Azure SQL. |
| **VM** | Virtual Machine | Machine virtuelle (compute IaaS). |
| **VMSS** | Virtual Machine Scale Set | Groupe de VM identiques avec autoscaling. |
| **VNet** | Virtual Network | Réseau privé virtuel isolé dans Azure. |
| **VPN** | Virtual Private Network | Tunnel réseau chiffré (accès distant/site à site). |
| **WAF** | Web Application Firewall | Pare-feu applicatif web (intégré à Application Gateway). |
| **YAML** | YAML Ain't Markup Language | Format de configuration lisible (ex. cloud-init). |
| **ZRS** | Zone-Redundant Storage | Réplication du stockage entre plusieurs zones d'une région. |

---

## Termes essentiels non-acronymes (rappel)

| Terme | Définition succincte |
|---|---|
| **Azure Bastion** | Service d'accès SSH/RDP sécurisé aux VM sans IP publique. |
| **Blob** | *Binary Large Object* : objet (fichier) stocké dans un Storage Account. |
| **Cloud-init** | Mécanisme de configuration d'une VM Linux au premier démarrage. |
| **Defender for Cloud** | Service de posture et protection de sécurité (Secure Score, recommandations). |
| **Entra ID** | Annuaire d'identité Microsoft (ex-Azure AD) : utilisateurs, groupes, applications. |
| **Drift** | Écart entre le code Terraform et l'état réel de l'infrastructure. |
| **Provider** | Plugin Terraform pilotant une plateforme (ex. `azurerm`). |
| **State** | Fichier Terraform liant le code aux ressources réelles. |
| **Tag** | Métadonnée clé/valeur attachée à une ressource (gouvernance, FinOps). |
| **Tenant** | Instance d'annuaire Entra ID représentant une organisation. |
| **Subscription** | Conteneur de facturation et de gouvernance des ressources Azure. |
| **Workspace (Log Analytics)** | Espace centralisé de stockage/interrogation des logs (KQL). |

> **Astuce mémo :** les trois pièges d'acronymes proches → **SLI** (mesuré) < **SLO** (objectif interne) < **SLA** (contrat) · **LRS/ZRS/GRS** = redondance locale / zone / géo · **IaaS/PaaS/SaaS** = contrôle décroissant, managé croissant.
