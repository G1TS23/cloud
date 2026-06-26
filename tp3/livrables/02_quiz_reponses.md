# TP3 — Quiz final (réponses)

**1. Différence entre `az vm stop` et `az vm deallocate` ?**
`az vm stop` éteint le système d'exploitation mais la VM reste **allouée** sur un hôte : le coût compute continue d'être facturé. `az vm deallocate` libère les ressources compute (état *Stopped (deallocated)*) et **stoppe la facturation compute** ; seuls les disques restent facturés.

**2. Pourquoi préférer Azure CLI au portail pour une tâche répétitive ?**
La CLI est reproductible, scriptable, versionnable et automatisable (cron, CI/CD). Le portail est manuel, lent et sujet aux erreurs humaines, sans trace exploitable.

**3. À quoi sert l'option `--query` ?**
À filtrer et reformater la sortie via JMESPath, pour n'extraire que les champs utiles (ex. nom, état, IP) et produire des sorties directement exploitables dans un script.

**4. Quel format de sortie pour réutiliser un résultat dans un script Bash ?**
`--output tsv` (valeurs séparées par tabulation, sans en-tête ni décoration), facile à parser avec `cut`, `awk` ou une boucle `for`.

**5. Pourquoi les tags sont-ils importants pour le FinOps ?**
Ils permettent de ventiler les coûts par application, environnement ou centre de coût, d'identifier les ressources arrêtables et de refacturer. Sans tags, l'analyse de coût est impossible automatiquement.

**6. Qu'est-ce qu'un runbook d'exploitation ?**
Une procédure documentée et reproductible décrivant comment réaliser une action d'exploitation (démarrer/arrêter un service, vérifier la santé, restaurer, traiter une alerte).

**7. Pourquoi éviter d'ouvrir SSH à tout Internet ?**
Exposer le port 22 à `0.0.0.0/0` offre une surface massive aux attaques par force brute et aux scans automatisés. On restreint SSH à une IP `/32` ou on passe par Azure Bastion / un VPN.

**8. Quelle commande liste les ressources d'un groupe ?**
`az resource list --resource-group <rg> --output table`.

**9. Quel service Azure suit les métriques et crée des alertes ?**
Azure Monitor (métriques, logs, alertes, action groups).

**10. Différence entre métrique et log ?**
Une **métrique** est une valeur numérique échantillonnée dans le temps (CPU %, mémoire) ; un **log** est un enregistrement d'événement horodaté, souvent textuel et détaillé (erreur applicative, accès). Les métriques servent au suivi de tendance et aux alertes seuil ; les logs au diagnostic.

**11. Pourquoi versionner les scripts d'exploitation ?**
Pour tracer l'historique des modifications, permettre la revue de code, revenir en arrière, partager une source unique fiable et éviter les divergences entre membres de l'équipe.

**12. Rôle de `DefaultAzureCredential` en Python ?**
Il fournit une chaîne d'authentification automatique (variables d'environnement, identité managée, session `az login`, etc.) pour s'authentifier auprès d'Azure sans coder de secret en dur.

**13. Pourquoi tester un script sur un environnement non productif ?**
Pour éviter qu'un bug ou une action destructive (arrêt, suppression) n'impacte la production. On valide le comportement sur `dev` avant tout usage réel.

**14. Deux risques d'un script d'administration mal sécurisé ?**
(1) Exécution d'une action destructive de masse sans confirmation (arrêt/suppression de toutes les VM) ; (2) fuite de secrets (clés, mots de passe) écrits en clair ou journalisés.

**15. Quelle information doit figurer dans un rapport d'exploitation ?**
Le périmètre, l'inventaire, l'état des ressources, les actions réalisées, la supervision/alertes, l'analyse sécurité et FinOps, et des recommandations exploitables.

**16. Pourquoi un budget Azure ne remplace-t-il pas une gouvernance des ressources ?**
Un budget alerte sur la dépense mais ne **bloque pas** la création de ressources et ne garantit ni le nettoyage ni le tagging. La gouvernance (tags, Azure Policy, RBAC, revues) traite la cause ; le budget ne traite que le symptôme.

**17. Deux actions simples pour réduire les coûts d'un environnement de dev ?**
(1) Désallouer les VM hors heures ouvrées ; (2) supprimer les ressources orphelines (disques, IP publiques non attachées).

**18. Pourquoi journaliser les actions d'un script ?**
Pour l'audit (qui a fait quoi et quand), le diagnostic en cas d'incident et la traçabilité réglementaire. Le journal de `vm-power.sh` en est un exemple.

**19. Différence entre IaC et script d'exploitation ?**
L'IaC (Terraform) décrit l'**état cible** de l'infrastructure de manière déclarative et idempotente (création/évolution). Un script d'exploitation réalise des **actions ponctuelles ou récurrentes** (impératif) sur une infra existante (arrêt, inventaire, contrôle).

**20. Trois contrôles intégrés dans un `healthcheck.sh` ?**
(1) Existence du groupe de ressources et d'au moins une VM ; (2) présence des tags obligatoires (`Application`, `Owner`) ; (3) existence d'alertes Monitor, du compte de stockage / conteneur, et d'une règle NSG autorisant le trafic web attendu.
