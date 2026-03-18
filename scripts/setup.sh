#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/var/log/setup.log"

touch "${LOG_FILE}" || { echo "Run this script with appropriate permissions"; exit 1; }

log() {
    local message="${1}"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - ${message}" | tee -a "${LOG_FILE}"
}

log "Starting setup script..."
log "Starting Environment Setup..."

# 1. Load .env
if [ -f ".env" ]; then
    log "Found .env file. Loading environment variables..."
    export $(grep -v '^#' .env | xargs)
else
    log "No .env file found. Please create one."
    exit 1
fi

# 2. Install OS packages
log "Updating Ubuntu packages..."
DEBIAN_FRONTEND=noninteractive apt-get update -yqq

log "Installing base packages..."
DEBIAN_FRONTEND=noninteractive apt-get install -yqq \
    curl wget git build-essential nginx

# 3. Install Node.js
log "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash - > /dev/null 2>&1

log "Installing Node.js packages..."
DEBIAN_FRONTEND=noninteractive apt-get install -yqq nodejs

log "Node.js version: $(node -v)"
log "npm version: $(npm -v)"

# 4. Install PM2
log "Installing PM2..."
npm install -g pm2

log "PM2 version: $(pm2 -v)"

# 5. Setup Nginx
log "Configuring Nginx..."

cat > /etc/nginx/sites-available/devops-app <<EOF
server {
    listen 80;
    server_name devops-ltc.io.vn;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

ln -sf /etc/nginx/sites-available/devops-app /etc/nginx/sites-enabled/devops-app
rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl restart nginx
systemctl enable nginx

log "Nginx configured successfully."

# 6. Create app directories
APP_DIR="/opt/my_app"
LOG_DIR="/var/log/my_app"

log "Creating directories..."
mkdir -p "${APP_DIR}/public/uploads"
mkdir -p "${LOG_DIR}"

APP_USER="${SUDO_USER:-root}"
chown -R "${APP_USER}:${APP_USER}" "${APP_DIR}" "${LOG_DIR}"

log "Setup completed successfully!"
