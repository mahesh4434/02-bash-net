#!/usr/bin/env bash
# 06_nginx_deploy.sh - idempotent nginx install + start + health check
set -euo pipefail

echo "Starting nginx deploy script..."

# detect package manager
if command -v apt-get >/dev/null 2>&1; then
  PKGMGR="apt"
elif command -v yum >/dev/null 2>&1; then
  PKGMGR="yum"
else
  echo "Unsupported OS/pkg manager"
  exit 1
fi

install_nginx() {
  if ! command -v nginx >/dev/null 2>&1; then
    echo "Installing nginx..."
    if [ "$PKGMGR" = "apt" ]; then
      sudo apt-get update -y
      sudo apt-get install -y nginx
    else
      sudo yum install -y epel-release
      sudo yum install -y nginx
    fi
  else
    echo "Nginx already installed."
  fi
}

start_enable_nginx() {
  echo "Ensuring nginx service enabled and started..."
  sudo systemctl enable nginx
  sudo systemctl start nginx || true
}

check_service() {
  if systemctl is-active --quiet nginx; then
    echo "Nginx service is active."
  else
    echo "Nginx service not active. journalctl -u nginx -n 50:"
    sudo journalctl -u nginx -n 50 --no-pager
    exit 1
  fi
}

health_check() {
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost || echo "000")
  echo "Health check status: $STATUS"
  if [[ "$STATUS" =~ ^2[0-9][0-9]$ ]]; then
    echo "OK"
  else
    echo "Health check failed"
    exit 2
  fi
}

install_nginx
start_enable_nginx
check_service
health_check

echo "Nginx deployment & health check complete."
