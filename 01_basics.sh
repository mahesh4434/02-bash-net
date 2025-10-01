#!/usr/bin/env bash
# 01_basics.sh - prints basic system info
set -euo pipefail

echo "=== Hostname ==="
hostname

echo -e "\n=== Uptime ==="
uptime -p

echo -e "\n=== Kernel ==="
uname -sr

echo -e "\n=== IP Addresses ==="
ip -c addr show | awk '/inet /{print $2 " on " $NF}'

echo -e "\n=== Disk usage ==="
df -h --total | sed -n '1,6p'

echo -e "\n=== Memory ==="
free -h

echo -e "\n=== Top processes (by CPU) ==="
ps aux --sort=-%cpu | head -n 10

echo -e "\n=== Listening TCP/UDP ports ==="
ss -lntup 2>/dev/null || netstat -tulnp 2>/dev/null

echo -e "\n=== Last 5 syslog messages ==="
if [ -f /var/log/syslog ]; then
  tail -n 5 /var/log/syslog
elif [ -f /var/log/messages ]; then
  tail -n 5 /var/log/messages
fi
