#!/usr/bin/env bash
# 03_log_parser.sh - parse nginx access log
set -euo pipefail

LOG=${1:-/var/log/nginx/access.log}

if [ ! -f "$LOG" ]; then
  echo "Log file not found: $LOG"
  exit 1
fi

echo "Parsing: $LOG"
echo -e "\nTop 10 IPs:"
awk '{print $1}' "$LOG" | sort | uniq -c | sort -rn | head -n 10

echo -e "\nTop 10 requested URLs:"
awk '{print $7}' "$LOG" | sort | uniq -c | sort -rn | head -n 10

echo -e "\nStatus code counts (top):"
awk '{codes[$9]++} END{ for (c in codes) print c, codes[c] }' "$LOG" | sort -nr -k2 | head -n 20

echo -e "\nTotal 4xx responses:"
awk '$9 ~ /^4/ {count++} END {print count+0}' "$LOG"

echo -e "\nTotal 5xx responses:"
awk '$9 ~ /^5/ {count++} END {print count+0}' "$LOG"
