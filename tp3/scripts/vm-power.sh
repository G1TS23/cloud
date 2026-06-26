#!/usr/bin/env bash
#
# vm-power.sh - Pilotage de l'alimentation des VM d'un groupe de ressources.
#
# Actions : start | stop | deallocate | status sur toutes les VM du groupe.
#
# Mesures de securite :
#   - refus d'executer sur un groupe dont le nom contient "prod" ;
#   - confirmation interactive avant toute action destructive (stop/deallocate) ;
#   - journalisation de chaque action dans logs/vm-power.log.
#
# Usage :
#   ./vm-power.sh <resource-group> <start|stop|deallocate|status>

set -euo pipefail

RG="${1:-}"
ACTION="${2:-}"
LOG_DIR="logs"
LOG_FILE="$LOG_DIR/vm-power.log"
mkdir -p "$LOG_DIR"

# Journalise un message horodate, a la fois a l'ecran et dans le fichier de log.
log() {
  local msg="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') | $RG | $ACTION | $msg" >> "$LOG_FILE"
  echo "$msg"
}

if [[ -z "$RG" || -z "$ACTION" ]]; then
  echo "Usage : $0 <resource-group> <start|stop|deallocate|status>" >&2
  exit 1
fi

# Garde-fou : jamais d'action de masse sur un environnement de production.
if [[ "$RG" == *prod* ]]; then
  echo "Refus : '$RG' ressemble a un groupe de PRODUCTION. Action interdite par ce script." >&2
  exit 2
fi

# Confirmation explicite avant les actions destructives.
confirm() {
  local prompt="$1"
  read -r -p "$prompt [oui/non] " reply
  [[ "$reply" == "oui" ]]
}

VMS=$(az vm list --resource-group "$RG" --query "[].name" --output tsv)
if [[ -z "$VMS" ]]; then
  log "Aucune VM trouvee dans $RG"
  exit 0
fi

if [[ "$ACTION" == "stop" || "$ACTION" == "deallocate" ]]; then
  echo "VM concernees par '$ACTION' :"
  echo "$VMS" | sed 's/^/  - /'
  if ! confirm "Confirmer l'action '$ACTION' sur ces VM ?"; then
    log "Action '$ACTION' annulee par l'utilisateur"
    exit 0
  fi
fi

for VM in $VMS; do
  log "Traitement de la VM : $VM"
  case "$ACTION" in
    start)
      az vm start --resource-group "$RG" --name "$VM" >/dev/null
      log "VM demarree : $VM"
      ;;
    stop)
      az vm stop --resource-group "$RG" --name "$VM" >/dev/null
      log "VM arretee (OS) : $VM"
      ;;
    deallocate)
      az vm deallocate --resource-group "$RG" --name "$VM" >/dev/null
      log "VM desallouee (cout compute stoppe) : $VM"
      ;;
    status)
      STATE=$(az vm get-instance-view \
        --resource-group "$RG" \
        --name "$VM" \
        --query "instanceView.statuses[?starts_with(code, 'PowerState/')].displayStatus" \
        --output tsv)
      log "Etat : $VM -> $STATE"
      ;;
    *)
      echo "Action inconnue : $ACTION" >&2
      exit 1
      ;;
  esac
done
