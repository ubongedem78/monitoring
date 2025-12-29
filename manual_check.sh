#!/bin/bash

RECIPIENT="ubong.edem@nnpcgroup.com"
GMAIL_USER="nuimsserverstatus@gmail.com"
GMAIL_PASS="znurbqstfgoohnzq"
SUBJECT="[NUIMS ALERT] Server Offline Detected"
LOGFILE="/Users/ubong/Desktop/code/monitoring/server_status.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

servers=(
  "Test Server|10.0.67.172|3389|On-Prem"
  "Cradle Hive Server|10.0.68.59|3389|On-Prem"
  "Avocet & Q-Pulse Server|10.0.64.58|3389|On-Prem"
  "Merak Server|10.0.67.171|3389|On-Prem"
  "QueStor Server|10.0.67.170|3389|On-Prem"
  "RefNo Server|10.0.67.169|3389|On-Prem"
  "ERDM-DV Server|10.0.66.205|3389|On-Prem"
  "ERDM-PD Server|10.0.66.206|3389|On-Prem"
  "NUIMS360 App Server Pub|20.56.16.231|3389|Azure"
  "NUIMS360 BI Bridge|20.50.195.204|3389|Azure"
  "NUIMS360 DB Server|172.17.1.4|22|Azure" 
)

OFFLINE_LIST=""
OFFLINE_COUNT=0

echo "===== CHECK STARTED: $TIMESTAMP =====" >> "$LOGFILE"

for SERVER in "${servers[@]}"; do
  NAME=$(echo "$SERVER" | cut -d'|' -f1)
  IP=$(echo "$SERVER" | cut -d'|' -f2)
  PORT=$(echo "$SERVER" | cut -d'|' -f3)
  ENV=$(echo "$SERVER" | cut -d'|' -f4)

  if ping -c 1 -t 1 "$IP" > /dev/null 2>&1; then
    echo "[$TIMESTAMP] OK: $NAME ($IP)" >> "$LOGFILE"
  else
    if nc -z -G 2 "$IP" "$PORT" > /dev/null 2>&1; then
      echo "[$TIMESTAMP] OK: $NAME ($IP)" >> "$LOGFILE"
    else
      echo "[$TIMESTAMP] CRITICAL: $NAME ($IP) is OFFLINE" >> "$LOGFILE"
      OFFLINE_LIST+="$NAME ($IP) - $ENV (Port $PORT Unreachable)\n"
      ((OFFLINE_COUNT++))
    fi
  fi
done

if [ $OFFLINE_COUNT -gt 0 ]; then
  HOUR=$(date +%H)
  [ "$HOUR" -lt 12 ] && WINDOW="Morning Check" || WINDOW="Close of Business"
  BODY_CONTENT=$(echo -e "$OFFLINE_LIST")

  python3 - <<EOF
import smtplib
from email.message import EmailMessage

msg = EmailMessage()
msg.set_content(f"""[NUIMS ALERT] Server Offline Detected
Date: $TIMESTAMP
Window: $WINDOW

The following servers are confirmed OFFLINE:
-------------------------------------------
$BODY_CONTENT
-------------------------------------------

Recommended Action: Immediate investigation required.""")

msg['Subject'] = '$SUBJECT - $WINDOW'
msg['From'] = '$GMAIL_USER'
msg['To'] = '$RECIPIENT'

try:
    with smtplib.SMTP_SSL('smtp.gmail.com', 465) as smtp:
        smtp.login('$GMAIL_USER', '$GMAIL_PASS')
        smtp.send_message(msg)
    print("SUCCESS")
except Exception as e:
    exit(1)
EOF

  if [ $? -eq 0 ]; then
    echo "Alert email sent successfully to $RECIPIENT" >> "$LOGFILE"
  else
    echo "ERROR: Email delivery failed." >> "$LOGFILE"
  fi
else
  echo "All servers online. No email sent." >> "$LOGFILE"
fi