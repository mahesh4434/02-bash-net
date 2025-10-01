#!/usr/bin/env bash
# 02_functions.sh - ping list of hosts and print summary
set -euo pipefail

HOSTS=("$@")
[ ${#HOSTS[@]} -gt 0 ] || {
  echo "Usage: $0 host1 host2 ..."
  exit 1
}

ping_host() {
  local host=$1
  if ping -c 3 -W 2 "$host" &>/dev/null; then
    echo "OK - $host reachable"
    return 0
  else
    echo "FAIL - $host unreachable"
    return 1
  fi
}

success=0
fail=0

for h in "${HOSTS[@]}"; do
  if ping_host "$h"; then
    success=$((success+1))
  else
    fail=$((fail+1))
  fi
done

echo
echo "Summary: total=${#HOSTS[@]} success=$success fail=$fail"
exit $(( fail > 0 ))
