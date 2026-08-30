#!/usr/bin/env bash
set -Eeuo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install --yes --no-install-recommends nginx

cat > /var/www/html/index.html <<EOF
<!doctype html>
<html lang="en">
  <head><meta charset="utf-8"><title>Highly Available Web Tier</title></head>
  <body>
    <h1>GCP highly available web tier</h1>
    <p>Served by $(hostname)</p>
  </body>
</html>
EOF

printf 'ok\n' > /var/www/html/healthz
systemctl enable nginx
systemctl restart nginx

