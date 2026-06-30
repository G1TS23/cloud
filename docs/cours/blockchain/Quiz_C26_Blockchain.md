# Quiz de révision — C26 : Blockchain & Smart Contracts

> Basé sur le cours magistral *« Blockchain et Smart Contracts »* (Bloc 4). Entraîne-toi d'abord, le **corrigé** est en seconde partie. Sections : A) QCM · B) Vrai/Faux justifié · C) Questions courtes · D) Mini-cas.

---

## L'essentiel en 6 points (avant de commencer)

1. La blockchain = **registre distribué, append-only**, blocs liés par **hash** → preuve **partagée, horodatée, vérifiable, difficile à falsifier**.
2. Utile quand **plusieurs acteurs** doivent se fier à un **historique commun** sans **autorité centrale** unique.
3. **Publique** (Ethereum, ouverte) / **privée** (1 organisation) / **permissionnée** (acteurs identifiés, ex. Hyperledger Fabric).
4. **Smart contract** = règles métier exécutées on-chain (chez Fabric = **chaincode**).
5. **On-chain** = empreinte/preuve/événement ; **off-chain** = documents, données personnelles, fichiers volumineux.
6. La blockchain **améliore** intégrité/traçabilité/non-répudiation/auditabilité — mais **ne garantit pas la véracité des données saisies** (*garbage in, garbage out*).

---

## A. QCM (1 seule bonne réponse)

**1.** Une blockchain est avant tout :
a) une base de données relationnelle plus rapide · b) un registre distribué structuré en blocs liés cryptographiquement · c) un service de stockage de fichiers · d) un pare-feu réseau

**2.** Dire qu'une blockchain est « append-only » signifie :
a) qu'on peut supprimer librement les blocs · b) qu'on ajoute des transactions sans réécrire silencieusement l'historique · c) qu'elle n'accepte qu'une transaction par jour · d) qu'elle est en lecture seule

**3.** Le **hash** sert principalement à :
a) chiffrer les communications réseau · b) accélérer le consensus · c) produire une empreinte permettant de détecter toute modification · d) stocker la clé privée

**4.** Le **consensus** est :
a) le programme métier exécuté on-chain · b) le mécanisme par lequel les participants s'accordent sur l'état valide du registre · c) le nom du jeton Ethereum · d) un type de base de données

**5.** Un **smart contract** est :
a) un contrat papier numérisé · b) un certificat TLS · c) un programme exécuté sur la blockchain appliquant des règles métier · d) un nœud du réseau

**6.** Chez **Hyperledger Fabric**, la logique de smart contract s'appelle :
a) Solidity · b) chaincode · c) bytecode · d) ledger

**7.** Une blockchain **permissionnée** se caractérise par :
a) un accès totalement ouvert à tous · b) l'absence de smart contracts · c) des participants **identifiés et autorisés** · d) l'absence d'historique

**8.** **Ethereum** est :
a) une blockchain privée d'entreprise · b) un service de stockage Azure · c) une blockchain publique exécutant des smart contracts (souvent en Solidity) · d) un protocole de consensus uniquement

**9.** Une **limite** principale d'Ethereum pour l'entreprise :
a) l'absence de smart contracts · b) le coût des transactions et la confidentialité des données · c) l'impossibilité d'horodater · d) l'absence d'écosystème développeur

**10.** **Azure Confidential Ledger** correspond plutôt à :
a) une blockchain publique · b) un registre **managé** append-only, résistant à la falsification · c) un service de machines virtuelles · d) un wallet Ethereum

**11.** Pourquoi conserver des données **off-chain** ?
a) parce que la blockchain ne sait pas horodater · b) pour y mettre les documents volumineux / données personnelles / confidentielles, et n'inscrire que l'empreinte on-chain · c) parce que l'on-chain est gratuit · d) pour supprimer l'historique

**12.** Ce que la blockchain **ne résout pas seule** :
a) l'horodatage · b) la détection des modifications · c) la **véracité des données saisies à l'entrée** · d) la non-répudiation

**13.** Un **risque** majeur côté smart contract :
a) une vulnérabilité technique ou logique exploitable · b) l'impossibilité de le tester · c) qu'il chiffre trop les données · d) qu'il supprime la blockchain

**14.** Stocker des **données personnelles directement on-chain** pose surtout un problème de :
a) performance réseau · b) conformité et droit à l'effacement · c) consensus · d) coût de stockage off-chain

**15.** La blockchain apporte une vraie valeur quand :
a) une seule autorité centrale gère tout · b) plusieurs acteurs doivent partager une preuve/un historique sans dépendre d'un acteur unique · c) on veut juste accélérer une base SQL · d) on n'a pas besoin de traçabilité

---

## B. Vrai / Faux (justifie en une phrase)

1. « Immuable » signifie qu'on ne peut **jamais** rien corriger.
2. Pour une entreprise, une blockchain publique est **toujours** le meilleur choix.
3. La clé privée sert à **signer** les transactions ; sa compromission entraîne une perte de contrôle.
4. Il faut stocker les **documents volumineux** directement sur la blockchain.
5. Hyperledger Fabric est une blockchain **privée/permissionnée** adaptée à des participants connus.
6. La blockchain **remplace** les bases de données, les API et la gouvernance des identités.

---

## C. Questions courtes

1. Quelle différence entre une base de données classique et une blockchain ?
2. Pourquoi dit-on qu'une blockchain est *append-only* ?
3. Dans quel cas choisir une blockchain **permissionnée** ?
4. Quel est le rôle d'un smart contract ?
5. Pourquoi éviter de stocker des données personnelles directement on-chain ?
6. Différence principale entre **Ethereum** et **Hyperledger Fabric** ?
7. Qu'est-ce qu'une **empreinte cryptographique** (hash) ?
8. Cite **deux risques** liés aux smart contracts.
9. Pourquoi la blockchain ne garantit-elle pas que les données saisies sont **vraies** ?
10. Donne un **cas d'usage SI** où la blockchain apporte une vraie valeur.

---

## D. Mini-cas

**Scénario.** Une entreprise de logistique veut tracer un produit de la fabrication à la livraison, avec plusieurs partenaires (usine, transporteur, distributeur). Chacun doit pouvoir ajouter un événement (fabrication, contrôle qualité, expédition, réception) et tous veulent un **historique partagé fiable** sans dépendre d'un acteur unique.

**Questions.**
1. Quel **type** de blockchain choisis-tu (publique / privée / permissionnée) et pourquoi ?
2. Que mets-tu **on-chain** et que gardes-tu **off-chain** ?
3. Quelles **règles** porterait le smart contract ?
4. Cite **deux mesures de sécurité** (clé privée, données perso…).

---
---

# Corrigé

## A. QCM

| Q | Rép. | Pourquoi (rappel) |
|---|---|---|
| 1 | **b** | Registre distribué, blocs liés cryptographiquement. |
| 2 | **b** | Append-only : on ajoute, on ne réécrit pas l'historique (on ajoute une transaction de correction). |
| 3 | **c** | Le hash = empreinte qui détecte toute modification. |
| 4 | **b** | Consensus = accord des participants sur l'état valide. |
| 5 | **c** | Programme on-chain appliquant des règles métier. |
| 6 | **b** | Fabric appelle ça **chaincode**. |
| 7 | **c** | Participants identifiés et autorisés. |
| 8 | **c** | Ethereum = blockchain publique, smart contracts (Solidity). |
| 9 | **b** | Coût des transactions + confidentialité (+ gouvernance publique). |
| 10 | **b** | Registre managé append-only, résistant à la falsification. |
| 11 | **b** | On garde off-chain les documents/données perso ; on-chain = empreinte/preuve. |
| 12 | **c** | *Garbage in* : elle prouve fidèlement… même une donnée fausse. |
| 13 | **a** | Vulnérabilité technique/logique → tests, audit de code. |
| 14 | **b** | Conformité + droit à l'effacement → données perso off-chain. |
| 15 | **b** | Plusieurs acteurs, preuve partagée, pas d'autorité unique. |

## B. Vrai / Faux

1. **Faux** — immuable = *append-only* ; on corrige en **ajoutant** une transaction, l'historique reste.
2. **Faux** — confidentialité, coût, performance, conformité peuvent imposer une **permissionnée** ou un **registre managé**.
3. **Vrai** — la clé privée signe les transactions ; compromise = transactions frauduleuses / perte de contrôle.
4. **Faux** — les documents volumineux restent **off-chain** ; on n'inscrit que l'**empreinte**.
5. **Vrai** — Fabric = privée/permissionnée, pour participants connus (consortium, supply chain).
6. **Faux** — elle **complète** le SI (app, API, stockage off-chain, identités, monitoring), elle ne les remplace pas.

## C. Questions courtes (réponses attendues)

1. La base classique repose souvent sur une **autorité centrale** (un admin peut modifier) ; la blockchain est un **registre distribué append-only** où l'historique est **partagé** et **difficile à falsifier** sans détection.
2. Parce qu'on **ajoute** des transactions sans remplacer l'ancien historique → piste d'audit robuste (on ajoute une correction plutôt que de supprimer).
3. Quand les **acteurs sont connus/identifiés** et que la **confidentialité** importe (consortium, supply chain, banque, assurance, industrie).
4. Porter et **appliquer automatiquement les règles métier** partagées, vérifiables et difficiles à falsifier (créer un actif, changer un statut, refuser une transaction non conforme, enregistrer un événement horodaté).
5. Pour des raisons de **conformité (RGPD) et de droit à l'effacement** : on ne peut pas effacer une donnée immuable → on stocke les données perso **off-chain** et seulement une **empreinte** on-chain.
6. **Ethereum** = publique, smart contracts Solidity, transparente mais coût/confidentialité/gouvernance publique ; **Hyperledger Fabric** = privée/**permissionnée**, participants identifiés, chaincode, plus confidentielle, orientée consortium.
7. Une **empreinte numérique** d'une donnée (hash) : toute modification du contenu change l'empreinte → permet de **détecter une altération**.
8. Deux parmi : **clé privée compromise**, **smart contract vulnérable**, **données personnelles on-chain**, **mauvais choix de plateforme**, **absence de gouvernance**.
9. Parce qu'elle garantit l'**intégrité** de ce qui est enregistré, pas la **véracité de l'entrée** : une info fausse mais validée sera conservée comme une « preuve fiable d'une info fausse » → besoin de **contrôles métier** et de **gouvernance des identités**.
10. Au choix : **traçabilité logistique**, **certification de documents/diplômes**, **journal d'audit inviolable** (modifs de droits, paiements, signatures).

## D. Mini-cas (corrigé indicatif)

1. **Permissionnée** (type Hyperledger Fabric ou registre managé) : les acteurs sont **connus** (usine, transporteur, distributeur), besoin de **confidentialité** et de **gouvernance** entre partenaires → pas une blockchain publique.
2. **On-chain** : identifiant produit, **événements horodatés** (statut, étape), empreintes éventuelles, identité de l'acteur. **Off-chain** : documents (bons de livraison, photos, certificats qualité), données personnelles, fichiers volumineux.
3. Le smart contract : créer le produit (vérifier qu'il n'existe pas), **vérifier que l'appelant est autorisé**, **valider la transition de statut** (fabrication → contrôle → expédition → réception), **refuser** une transition non conforme, **ajouter un événement horodaté** à l'historique.
4. Deux mesures : protéger les **clés privées** (coffre de secrets / Key Vault, rotation, MFA, séparation des rôles) ; garder les **données personnelles off-chain** (conformité) ; (+ audit du smart contract, gouvernance des identités).

---

> **Pour valider C26 :** savoir **expliquer le besoin**, **choisir la plateforme** adaptée (publique vs permissionnée vs registre managé), **décrire la logique d'un smart contract** et **justifier** comment la solution renforce traçabilité, sécurité et intégrité — sans la présenter comme une solution magique.
