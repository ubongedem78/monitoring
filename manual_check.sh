#!/bin/bash

servers=(
  "Test Server|10.0.67.172"
  "Cradle Hive Server|10.0.68.59"
  "Avocet & Q-Pulse Server|10.0.64.58"
  "Merak Server|10.0.67.171"
  "QueStor Server|10.0.67.170"
  "RefNo Server|10.0.67.169"
  "ERDM-DV Server|10.0.66.205"
  "ERDM-PD Server|10.0.66.206"
  "NUIMS360 App Server|20.56.16.231"
  "NUIMS360 BI Bridge|20.50.195.204"
)

LOGFILE="server_status.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "===== $TIMESTAMP =====" >> "$LOGFILE"

for SERVER in "${servers[@]}"; do
  NAME=$(echo "$SERVER" | cut -d'|' -f1)
  IP=$(echo "$SERVER" | cut -d'|' -f2)

  if curl -I --connect-timeout 5 -s "http://$IP" > /dev/null; then
    echo "$NAME ($IP) : ONLINE" >> "$LOGFILE"
  else
    echo "$NAME ($IP) : OFFLINE" >> "$LOGFILE"
  fi
done

echo "" >> "$LOGFILE"
echo "Server status check completed. Log saved to $LOGFILE."