# Projet de validation — BC04 : Optimiser le SI par le Cloud Computing

> **Auteur :** Olivier Falahi · **Mode :** individuel · **Type :** mise en situation (écrit + ordinateur)
> **Livrables :** 1) **application déployée** · 2) **rapport de sécurisation**
> **Compétences du projet : C21 → C25** · **Barème projet : 10 critères × 5 pts = 50 pts**

> ⚠️ **C26 (blockchain) est évaluée séparément dans un quiz → HORS périmètre de ce projet.** (Révision blockchain à préparer à part.)

⏱️ **~7 h.** Priorité : un **MVP déployé et démontrable** sur chaque compétence. Chaque critère vaut 5 pts → **ne laisser aucun critère à 0**.

---

## 0. Compétences & grille (ce qui est noté dans le projet)

| Compétence | Critères | Attendu pour viser « Professionnel » /5 |
|---|---|---|
| **C21** Intégrer des services cloud (API, plateforme) | C21.1 les services améliorent les fonctionnalités · C21.2 l'automatisation réduit les erreurs / accélère | Plusieurs services Azure **utilisés ensemble** via SDK/API, apportant une vraie valeur fonctionnelle |
| **C22** Automatiser config & gestion des ressources | C22.1 config répond au besoin · C22.2 déploiements **reproductibles** | **Terraform** (IaC) qui déploie tout, rejouable (`plan/apply/destroy`) |
| **C23** Administrer & optimiser l'infra | C23.1 script/programme efficace · C23.2 choix techno pertinent | **Scripts Bash/Python** (CLI/SDK) d'admin/optimisation, robustes et justifiés |
| **C24** Analyser & optimiser la performance | C24.1 indicateurs pertinents · C24.2 le monitoring permet l'analyse | **App Insights / Azure Monitor** : métriques, dashboard, alerte |
| **C25** Implémenter la sécurité | C25.1 répond aux besoins sécu/réglementation · C25.2 solutions **fonctionnelles** | HTTPS, **Key Vault**, RBAC moindre privilège, accès restreint, identité managée **+ rapport** |

---

## 1. Concept retenu : « DocBox » (proposition)

> _Application simple, déployable vite, et qui mobilise naturellement plusieurs services + la sécurité. À adapter si tu préfères un autre thème (gestion de tâches, commandes, notes…)._

**DocBox** = petite **application web de gestion de documents** : l'utilisateur se connecte, **téléverse des fichiers** (stockés dans Blob), consulte/recherche ses documents (métadonnées en base). Tous les secrets passent par Key Vault, l'app est supervisée et sécurisée.

### Architecture cible

| Couche | Service Azure | Compétence servie |
|---|---|---|
| Web app | **Azure App Service** (Node.js ou Python) | C21, C24 |
| Données | **Azure SQL Database** (serverless) — métadonnées | C21 |
| Fichiers | **Storage Account / Blob** (privé) | C21, C25 |
| Secrets | **Azure Key Vault** + **Managed Identity** | C25 |
| Identité & droits | **Entra ID + RBAC** (moindre privilège) | C25 |
| Observabilité | **Application Insights + Azure Monitor** | C24 |
| Déploiement | **Terraform** + scripts | C22, C23 |

> 💡 **Booster C21.1 (« les services améliorent les fonctionnalités ») :** intégrer **un service managé à valeur ajoutée** — ex. **Azure AI Document Intelligence / Vision (OCR)** pour extraire automatiquement le texte d'un document téléversé, ou **Azure Cognitive Search** pour la recherche plein-texte. C'est ce qui fait passer C21 de « suffisant » à « professionnel ». _(Optionnel si le temps manque.)_

---

## 2. Plan de bataille (~7 h) — ordre conseillé

| Bloc | Durée | Quoi | Compétences | Dossier |
|---|---|---|---|---|
| 0 | 15 min | Cadrer le scope, figer le concept | — | `projet/` |
| 1 | 90 min | **App** qui tourne (auth simple, upload Blob, liste/recherche) | C21 | `app/` |
| 2 | 90 min | **Terraform** : App Service + base + Storage + Key Vault | C22 | `infra/` |
| 3 | 60 min | **Sécurité** : HTTPS only, Key Vault + Managed Identity, RBAC, accès restreint | C25 | `app/`, `infra/` |
| 4 | 60 min | **Monitoring** : App Insights + 2-3 indicateurs + 1 alerte + dashboard | C24 | `monitoring/` |
| 5 | 45 min | **Scripts** admin/optimisation (deploy, healthcheck, cost) | C23 | `scripts/` |
| 6 | 60 min | **Rapport de sécurisation** + captures de preuves | C25 (+ tous) | `livrables/` |
| 7 | 20 min | Vérif finale, **nettoyage Azure**, remise | — | — |

> Marge plus confortable sans la blockchain. Si retard : viser « Suffisant » (3 pts) **partout** avant de peaufiner un point en « Professionnel ».

---

## 3. Livrables attendus

| # | Livrable | Emplacement | Statut |
|---|---|---|---|
| 1 | **Application déployée** (URL Azure + code) | `app/` + URL | ⬜ |
| 2 | **Rapport de sécurisation** | `livrables/Rapport_securisation.md` | ⬜ |
| 3 | Code IaC Terraform | `infra/` | ⬜ |
| 4 | Scripts d'administration/optimisation | `scripts/` | ⬜ |
| 5 | Preuves (captures app, monitoring, sécurité) | `screenshots/` | ⬜ |

---

## 4. Checklist par critère

- [ ] **C21.1** ≥ 3 services Azure utilisés **ensemble** qui apportent de la valeur (bonus : service IA/recherche).
- [ ] **C21.2** Au moins un processus **automatisé** via les services (déploiement, ou traitement à l'upload).
- [ ] **C22.1** Config Terraform correcte et adaptée au besoin.
- [ ] **C22.2** `terraform apply` **reproductible** démontré (re-run sans casse).
- [ ] **C23.1** Script Bash/Python **fonctionnel** (deploy / healthcheck / cost).
- [ ] **C23.2** Choix de techno **justifié** (pourquoi Terraform, pourquoi Python/Bash…).
- [ ] **C24.1** 2-3 **indicateurs pertinents** (latence, CPU, dispo, taux d'erreur).
- [ ] **C24.2** Dashboard/alerte qui **permet d'analyser** la perf (pas juste des courbes).
- [ ] **C25.1** Mesures reliées à un **besoin** sécu/conformité (RGPD, accès, confidentialité).
- [ ] **C25.2** Sécurité **fonctionnelle** : HTTPS effectif, secret dans Key Vault, accès restreint vérifié.

---

## 5. Organisation du dossier

```
projet/
├── README.md            # cahier de bord (ce fichier)
├── sujet/               # énoncé officiel s'il existe (PDF)
├── app/                 # code de l'application web (C21, C24)
├── infra/               # Terraform : App Service, base, Storage, Key Vault (C22)
├── scripts/             # Bash/Python d'admin & optimisation (C23)
├── monitoring/          # config / requêtes / alertes + captures (C24)
├── livrables/           # rapport de sécurisation + annexes (C25)
├── screenshots/         # preuves d'exécution
└── notes/               # brouillons
../dist/projet/          # rendu final compilé (PDF / ZIP)
```

---

## 6. Rappels (réflexes des TP — réutilisables ici)

- **Azure for Students :** région `swedencentral`. **App Service** évite la gestion d'une VM → plus rapide à déployer et à sécuriser.
- **Sécurité :** jamais de secret en clair (→ **Key Vault** + identité managée), **HTTPS only**, RBAC moindre privilège, base/stockage **non publics**.
- **Terraform :** lire le `plan`, state hors Git, `destroy` à la fin (⚠️ après remise + captures).
- **Coût :** tags + budget ; arrêter/supprimer après la remise.
- Fiches : [`../docs/revision/`](../docs/revision/) · [synthèse globale](../docs/revision/Fiche_synthese_globale_Cloud_Azure.pdf).

> **Décisions :**
> - **Base : Azure SQL Database (serverless)** ✅ acté.
> - **Stack app : à confirmer** (Node.js Express ou Python Flask/FastAPI) — après lecture de l'énoncé.
> - **Énoncé détaillé : en attente** → à déposer dans `projet/sujet/`, puis cadrage précis (le concept « DocBox » n'est qu'une proposition de repli).
