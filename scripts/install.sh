#!/bin/bash

# n8n Telegram Bot Installation Script for First VDS
# This script installs Docker, Docker Compose, and sets up n8n with all dependencies

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root"
   exit 1
fi

print_info "Starting n8n Telegram Bot installation..."

# Update system
print_info "Updating system packages..."
apt-get update && apt-get upgrade -y
print_success "System updated"

# Install required packages
print_info "Installing required packages..."
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    ufw \
    fail2ban \
    htop \
    nano
print_success "Required packages installed"

# Install Docker
if ! command -v docker &> /dev/null; then
    print_info "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    print_success "Docker installed"
else
    print_success "Docker already installed"
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    print_info "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    print_success "Docker Compose installed"
else
    print_success "Docker Compose already installed"
fi

# Setup firewall
print_info "Configuring firewall..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable
print_success "Firewall configured"

# Configure fail2ban
print_info "Configuring fail2ban..."
cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
EOF
systemctl restart fail2ban
print_success "fail2ban configured"

# Create project directory
PROJECT_DIR="/opt/n8n-telegram-bot"
print_info "Creating project directory at $PROJECT_DIR..."
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Copy deployment files
print_info "Please upload your project files to $PROJECT_DIR"
print_info "Required files:"
echo "  - deployment/docker-compose.yml"
echo "  - deployment/.env.production"
echo "  - nginx/nginx.conf"
echo "  - nginx/conf.d/n8n.conf"
echo "  - workflows/telegram-bot-deepseek.json"

# Create necessary directories
mkdir -p nginx/conf.d certbot/conf certbot/www workflows credentials landing

# Generate encryption key
print_info "Generating n8n encryption key..."
ENCRYPTION_KEY=$(openssl rand -hex 16)
echo "N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY" >> .env.generated
print_success "Encryption key generated and saved to .env.generated"

# Create systemd service
print_info "Creating systemd service..."
cat > /etc/systemd/system/n8n-telegram-bot.service << EOF
[Unit]
Description=n8n Telegram Bot
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$PROJECT_DIR
ExecStart=/usr/local/bin/docker-compose -f deployment/docker-compose.yml up -d
ExecStop=/usr/local/bin/docker-compose -f deployment/docker-compose.yml down
ExecReload=/usr/local/bin/docker-compose -f deployment/docker-compose.yml restart

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable n8n-telegram-bot
print_success "Systemd service created"

# Create backup script
print_info "Creating backup script..."
cat > $PROJECT_DIR/scripts/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backup/n8n"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

# Backup database
docker-compose -f deployment/docker-compose.yml exec -T postgres pg_dump -U $POSTGRES_USER $POSTGRES_DB | gzip > $BACKUP_DIR/db_$DATE.sql.gz

# Backup n8n data
tar -czf $BACKUP_DIR/n8n_data_$DATE.tar.gz -C /var/lib/docker/volumes n8n-telegram-bot_n8n_data

# Keep only last 7 days of backups
find $BACKUP_DIR -name "*.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
EOF
chmod +x $PROJECT_DIR/scripts/backup.sh

# Add cron job for daily backups
(crontab -l 2>/dev/null; echo "0 3 * * * $PROJECT_DIR/scripts/backup.sh >> /var/log/n8n-backup.log 2>&1") | crontab -
print_success "Backup system configured"

# Create monitoring script
print_info "Creating monitoring script..."
cat > $PROJECT_DIR/scripts/monitor.sh << 'EOF'
#!/bin/bash
# Check if services are running
services=("postgres" "n8n" "nginx" "redis")
for service in "${services[@]}"; do
    if ! docker ps | grep -q $service; then
        echo "Service $service is not running. Restarting..."
        docker-compose -f deployment/docker-compose.yml restart $service
    fi
done
EOF
chmod +x $PROJECT_DIR/scripts/monitor.sh

# Add monitoring cron job
(crontab -l 2>/dev/null; echo "*/5 * * * * $PROJECT_DIR/scripts/monitor.sh >> /var/log/n8n-monitor.log 2>&1") | crontab -
print_success "Monitoring configured"

# Instructions
echo ""
echo "=========================================="
echo "Installation completed!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Copy your .env.production file to $PROJECT_DIR/deployment/"
echo "2. Update domain name in nginx config files"
echo "3. Copy your workflow JSON to $PROJECT_DIR/workflows/"
echo "4. Run: cd $PROJECT_DIR && docker-compose -f deployment/docker-compose.yml up -d"
echo "5. Setup SSL: ./scripts/setup-ssl.sh your-domain.com"
echo ""
echo "Generated encryption key saved in: .env.generated"
echo "Add this to your .env.production file!"
echo ""
echo "Access n8n at: https://your-domain.com"
echo "Default login set in .env.production"
echo ""
print_success "Installation script completed!"
