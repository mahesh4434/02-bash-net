#!/usr/bin/env bash
# 04_scheduler.sh - install nginx log rotation script and cron job
set -euo pipefail

ROT_SCRIPT="/usr/local/bin/log_rotate_nginx.sh"
CRON_LINE="0 2 * * * ${ROT_SCRIPT} >> /var/log/nginx/log_rotate_cron.log 2>&1"

# create rotation script
sudo tee "$ROT_SCRIPT" > /dev/null <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
LOG_DIR="/var/log/nginx"
ARCHIVE_DIR="${LOG_DIR}/archived"
mkdir -p "$ARCHIVE_DIR"
TIMESTAMP=$(date +%F_%H%M%S)

for f in access.log error.log; do
  if [ -f "${LOG_DIR}/${f}" ]; then
    mv "${LOG_DIR}/${f}" "${ARCHIVE_DIR}/${f}.${TIMESTAMP}"
  fi
done

# compress
gzip -f "${ARCHIVE_DIR}"/*."${TIMESTAMP}" 2>/dev/null || true

# ask nginx to reopen logs (works for standard installs)
if command -v nginx >/dev/null 2>&1; then
  nginx -s reopen 2>/dev/null || {
    if [ -f /run/nginx.pid ]; then
      kill -USR1 "$(cat /run/nginx.pid)" 2>/dev/null || true
    fi
  }
fi

# cleanup older than 7 days
find "$ARCHIVE_DIR" -type f -mtime +7 -name '*.gz' -delete
EOF

sudo chmod +x "$ROT_SCRIPT"
echo "Rotation script installed: $ROT_SCRIPT"

# install cron job if not present
( crontab -l 2>/dev/null | grep -F "$ROT_SCRIPT" ) || {
  ( crontab -l 2>/dev/null; echo "$CRON_LINE" ) | crontab -
  echo "Cron job installed."
}
