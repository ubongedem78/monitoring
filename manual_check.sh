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

for entry in "${servers[@]}"; do
  IFS='|' read -r name ip <<< "$entry"
  echo "Checking $name ($ip)"

  if ping -c 2 -W 3 "$ip" >/dev/null 2>&1; then
    echo "  RESULT: ONLINE (ping)"
  else
    echo "  ping blocked or failed – trying TCP 22"
    if nc -z -w 3 "$ip" 22 >/dev/null 2>&1; then
      echo "  RESULT: ONLINE (TCP 22)"
    else
      echo "  RESULT: OFFLINE or BLOCKED"
    fi
  fi

  echo "--------------------------------"
done

