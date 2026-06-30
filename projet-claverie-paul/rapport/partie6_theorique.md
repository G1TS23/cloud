# Partie 6 — Questions théoriques

> Réponses courtes, précises et contextualisées au cas NovaRetail.
> **Barème : 2 pts** — exactitude, précision, contextualisation, compréhension des notions (dont traçabilité blockchain, C26).

---

## 8.1 — Questions Cloud, Azure et exploitation

**1. Différence IaaS / PaaS / SaaS + exemple Azure**

- **IaaS** (Infrastructure as a Service) : le fournisseur gère le matériel ; le client gère OS, runtime et application. *Exemple : Azure Virtual Machines* — c'est le modèle des VM web de NovaRetail.
- **PaaS** (Platform as a Service) : le fournisseur gère aussi l'OS et le runtime ; le client n'apporte que l'application/les données. *Exemple : Azure Database for MySQL Flexible Server* — la base managée de NovaRetail.
- **SaaS** (Software as a Service) : application complète consommée telle quelle. *Exemple : Microsoft 365*.

**2. Pourquoi une base managée plutôt qu'une base sur VM ?**
Parce qu'elle décharge l'équipe de l'administration : **sauvegardes automatiques, patching, haute disponibilité, chiffrement et supervision** sont intégrés. Pour NovaRetail, cela supprime le risque de la base MySQL non maintenue sur VM et améliore sécurité et disponibilité sans surcharge d'exploitation.

**3. Rôle d'un Virtual Network dans Azure ?**
C'est le **réseau privé isolé** dans lequel on place les ressources. Il permet la **segmentation en subnets**, le contrôle des flux (NSG), l'adressage privé et la communication interne sécurisée. Pour NovaRetail, il isole la couche web de la couche données.

**4. Différence entre un NSG et une règle RBAC ?**
- **NSG** : contrôle le **trafic réseau** (autoriser/refuser des flux par IP, port, protocole) — plan *réseau*.
- **RBAC** : contrôle **qui peut faire quoi** sur les ressources Azure (gérer, lire, supprimer) — plan *gestion/identité*.
En résumé : le NSG protège les **paquets**, le RBAC protège les **actions** sur les ressources.

**5. Pourquoi l'Infrastructure as Code réduit-elle les risques d'exploitation ?**
Parce que l'infrastructure est **décrite dans du code versionné, reproductible et revu**. On élimine les erreurs manuelles, on rejoue le même déploiement à l'identique (`plan/apply`), on trace les changements (Git) et on peut reconstruire rapidement en cas d'incident. Démontré pour NovaRetail : `terraform plan` confirme « No changes » (aucune dérive).

**6. Que contient le state Terraform et pourquoi le protéger ?**
Le state est le **fichier de correspondance entre le code et les ressources réelles** (IDs, attributs, et parfois des **valeurs sensibles** comme des secrets). Il doit être protégé car sa perte fait perdre le contrôle de l'infra, et sa fuite peut exposer des secrets. → **State distant chiffré et verrouillé** (backend Azure Storage), jamais sur un poste local.

**7. Différence entre monitoring, logs et alertes ?**
- **Monitoring** : collecte et visualisation de **métriques** (ex. CPU, disponibilité) dans le temps.
- **Logs** : **événements détaillés** horodatés (accès, erreurs, actions) pour le diagnostic et l'audit.
- **Alertes** : **déclencheurs automatiques** lorsqu'un seuil/condition est franchi, qui notifient ou agissent.
Le monitoring observe, les logs expliquent, les alertes réagissent.

**8. Trois métriques utiles pour piloter une application web**
Latence (temps de réponse), taux d'erreurs HTTP (5xx/4xx), et taux d'utilisation des ressources (CPU/mémoire). *(Autres pertinentes : disponibilité, débit de requêtes.)*

**9. Pourquoi les tags sont-ils essentiels pour le FinOps ?**
Parce qu'ils permettent de **ventiler et imputer les coûts** par application, environnement, centre de coût ou propriétaire. Sans tags, la facture Azure est globale et inexploitable ; avec eux, on peut faire des budgets ciblés, détecter les dérives et refacturer.

**10. Trois mesures de sécurité prioritaires avant une mise en production**
1. **Fermer les expositions réseau inutiles** (pas de SSH/BDD ouverts sur Internet, NSG stricts).
2. **Gérer les secrets correctement** (Key Vault + identité managée, aucun secret en clair/versionné).
3. **Appliquer le moindre privilège RBAC** + activer **journalisation/audit** et sauvegardes testées.

---

## 8.2 — Questions courtes — traçabilité blockchain

**11. Objectif principal d'une blockchain dans un SI ?**
Garantir l'**intégrité et la traçabilité infalsifiable** des données/transactions via un registre distribué, partagé et inviolable, sans dépendre d'un tiers de confiance unique.

**12. Composant permettant de détecter qu'une donnée a été modifiée ?**
La **fonction de hachage (hash) cryptographique** : chaque bloc contient l'empreinte de son contenu et celle du bloc précédent ; toute modification change le hash et rompt la chaîne, rendant l'altération détectable.

**13. Pourquoi dit-on qu'une blockchain est append-only ?**
Parce qu'on ne peut qu'**ajouter** de nouveaux blocs : les blocs existants sont chaînés par leurs hash, donc immuables — on ne peut ni modifier ni supprimer une donnée déjà inscrite sans invalider toute la chaîne.

**14. Hyperledger Fabric — quel contexte d'entreprise ?**
Les contextes **privés / de consortium** (permissionnés) : plusieurs organisations connues qui partagent un registre avec contrôle des accès et confidentialité (ex. supply chain, échanges B2B). Idéal quand les participants sont identifiés.

**15. Ethereum — quels usages principaux ?**
Les usages **publics et décentralisés** reposant sur des **smart contracts** : cryptomonnaie, DeFi, NFT, applications décentralisées (dApps) ouvertes à tous.

**16. Azure Confidential Ledger — quel besoin ?**
Le besoin de **journalisation/traçabilité inviolable et confidentielle** : stocker des enregistrements sensibles (logs d'audit, preuves) dans un registre **infalsifiable, vérifiable cryptographiquement et protégé** (environnement d'exécution de confiance). Utile pour la conformité et l'intégrité des journaux d'audit de NovaRetail.

**17. Rôle d'un smart contract ?**
C'est un **programme exécuté automatiquement sur la blockchain** qui applique des règles convenues lorsque des conditions sont remplies (logique « if/then »), sans intermédiaire, de façon déterministe et traçable.

**18. Pourquoi stocker les documents lourds/sensibles off-chain ?**
Parce que la blockchain est **coûteuse, lente et publique/réplicée** : on n'y stocke que l'**empreinte (hash) et les métadonnées**, le document restant dans un stockage externe (ex. Blob privé). On garde la **preuve d'intégrité on-chain** tout en préservant performance, coût et confidentialité (RGPD).

**19. Que peut provoquer la compromission d'une clé privée ?**
L'**usurpation d'identité** : l'attaquant peut signer des transactions au nom de la victime (vol de fonds/actifs, écriture de données frauduleuses). Comme la blockchain est immuable, ces actions sont **irréversibles**.

**20. Bonne pratique pour les données personnelles dans une solution blockchain ?**
**Ne pas inscrire de données personnelles en clair on-chain** (immuabilité incompatible avec le droit à l'effacement RGPD) : stocker les données personnelles **off-chain** (chiffrées, supprimables) et ne conserver sur la chaîne qu'une **empreinte/anonymisation** servant de preuve d'intégrité.
