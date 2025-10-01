# 02-bash-net
Week 2 — Bash & Networking scripts and Troubleshooting Playbook

## Scripts
- `01_basics.sh` - Print system info
- `02_functions.sh` - Ping multiple hosts with error handling
- `03_log_parser.sh` - Parse nginx access logs (top IPs, status codes)
- `04_scheduler.sh` - Install nginx log rotation script + cron job
- `05_http_diag.sh` - Curl health check script
- `06_nginx_deploy.sh` - Idempotent nginx install + health check

## Troubleshooting Playbook

### Tracing a 502 Bad Gateway
**Symptom:** Nginx (or LB) returns 502.  
**Steps:**
1. `sudo tail -n 200 /var/log/nginx/error.log` — look for upstream errors.
2. Check upstream address in nginx config (`/etc/nginx/sites-enabled/*` or `/etc/nginx/nginx.conf`).
3. Validate backend directly: `curl -v http://127.0.0.1:8080` (use backend port).
4. Check backend service: `systemctl status <service>` and backend logs.
5. If backend is listening on a different interface or port, fix upstream or bind backend correctly.
6. After fixing, `sudo nginx -t && sudo systemctl reload nginx`.

### Tracing a 504 Gateway Timeout
**Symptom:** Nginx returns 504.  
**Steps:**
1. Check nginx error log for proxies timing out.
2. Check `proxy_read_timeout`/`proxy_connect_timeout` in your nginx config.
3. Test backend latency: `curl -m 5 http://backend:8080/endpoint`.
4. Inspect backend (CPU, memory, DB slow queries).
5. Consider increasing proxy timeout or optimizing backend queries.
6. Reload nginx after config change.

### Common `awk` one-liners
- Top IPs:
  ```bash
  awk '{print $1}' access.log | sort | uniq -c | sort -nr | head -n 10
