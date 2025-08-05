#!/bin/bash

# SSL Setup Script for n8n
# Usage: ./setup-ssl.sh your-domain.com your-email@example.com

set -e

# Check arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <domain> <email>"
    echo "Example: $0 n8n.example.com admin@example.com"
    exit 1
fi

DOMAIN=$1
EMAIL=$2
PROJECT_DIR="/opt/n8n-telegram-bot"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}→ Setting up SSL for $DOMAIN${NC}"

# Update nginx config with domain
sed -i "s/your-domain.com/$DOMAIN/g" $PROJECT_DIR/nginx/conf.d/n8n.conf

# Start nginx without SSL first
docker-compose -f $PROJECT_DIR/deployment/docker-compose.yml up -d nginx

# Get initial certificate
echo -e "${YELLOW}→ Obtaining SSL certificate...${NC}"
docker-compose -f $PROJECT_DIR/deployment/docker-compose.yml run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    -d $DOMAIN \
    -d www.$DOMAIN

# Restart nginx with SSL
echo -e "${YELLOW}→ Restarting nginx with SSL...${NC}"
docker-compose -f $PROJECT_DIR/deployment/docker-compose.yml restart nginx

# Setup auto-renewal
echo -e "${YELLOW}→ Setting up auto-renewal...${NC}"
cat > $PROJECT_DIR/scripts/renew-ssl.sh << EOF
#!/bin/bash
cd $PROJECT_DIR
docker-compose -f deployment/docker-compose.yml run --rm certbot renew
docker-compose -f deployment/docker-compose.yml restart nginx
EOF
chmod +x $PROJECT_DIR/scripts/renew-ssl.sh

# Add cron job for renewal
(crontab -l 2>/dev/null; echo "0 2 * * 1 $PROJECT_DIR/scripts/renew-ssl.sh >> /var/log/ssl-renewal.log 2>&1") | crontab -

echo -e "${GREEN}✓ SSL setup completed!${NC}"
echo -e "${GREEN}✓ Your site is now available at: https://$DOMAIN${NC}"
echo -e "${GREEN}✓ Certificate will auto-renew every Monday at 2 AM${NC}"
