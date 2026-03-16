#!/usr/bin/env bash
set -e euo pipefail

LOG_FILE="${"/var/log/setup.log"}"

touch "${LOG_FILE}" || {echo "Run this script with appropriate permissions"; exit 1;}

log() {
    local message="${1}"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - ${message}" | tee -a "${LOG_FILE}"
}

log "Starting setup script..."
log "Starting Environment Setup..."

# 1.No Hardcoded Secrets
if [ -f ".env" ]; then
    log "Found .env file. Loading environment variables from .env file..."
    export $(grep -v '^#' .env | xargs)
else 
    log "No .env file found. Please create a .env file with the necessary environment variables."
    exit 1
fi

# 2. Install Os Packages
log "Updating Ubuntu packages..."
DEBIAN_FRONTEND=noninteractive apt-get update -yqq #&& apt-get upgrade -yqq (Upgrade can cause issues in some environments, so it's commented out for now)
log "Installing necessary OS packages..."
DEBIAN_FRONTEND=noninteractive apt-get install -yqq curl wget git build-essential

# 3. Install Runtimes
log "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash - > dev/null #Only logs the error if the setup script fails, otherwise it will be silent

log "Installing Node.js packages..."
DEBIAN_FRONTEND=noninteractive apt-get install -yqq nodejs 

log "Node.js version: $(node -v)"
log "npm version: $(npm -v)"

# 4. Creating Necessary Directories
log "Creating necessary directories..."
mkdir -p "$base_dir"