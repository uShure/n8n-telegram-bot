#!/bin/bash

# n8n Telegram Bot Management Script
# Easy management interface for common tasks

PROJECT_DIR="/opt/n8n-telegram-bot"
COMPOSE_FILE="$PROJECT_DIR/deployment/docker-compose.yml"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Functions
print_header() {
    clear
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}     n8n Telegram Bot Management${NC}"
    echo -e "${BLUE}==========================================${NC}"
    echo ""
}

print_menu() {
    echo -e "${YELLOW}Main Menu:${NC}"
    echo "1) View Status"
    echo "2) Start Services"
    echo "3) Stop Services"
    echo "4) Restart Services"
    echo "5) View Logs"
    echo "6) Backup Now"
    echo "7) Update System"
    echo "8) View Resources"
    echo "9) Check Bot Webhook"
    echo "10) SSL Certificate Status"
    echo "11) Database Shell"
    echo "0) Exit"
    echo ""
}

view_status() {
    print_header
    echo -e "${YELLOW}Service Status:${NC}"
    cd $PROJECT_DIR
    docker-compose -f deployment/docker-compose.yml ps
    echo ""
    read -p "Press Enter to continue..."
}

start_services() {
    print_header
    echo -e "${YELLOW}Starting services...${NC}"
    cd $PROJECT_DIR
    docker-compose -f deployment/docker-compose.yml up -d
    echo -e "${GREEN}✓ Services started${NC}"
    sleep 2
}

stop_services() {
    print_header
    echo -e "${YELLOW}Stopping services...${NC}"
    cd $PROJECT_DIR
    docker-compose -f deployment/docker-compose.yml stop
    echo -e "${GREEN}✓ Services stopped${NC}"
    sleep 2
}

restart_services() {
    print_header
    echo -e "${YELLOW}Restarting services...${NC}"
    cd $PROJECT_DIR
    docker-compose -f deployment/docker-compose.yml restart
    echo -e "${GREEN}✓ Services restarted${NC}"
    sleep 2
}

view_logs() {
    print_header
    echo -e "${YELLOW}Select service:${NC}"
    echo "1) All services"
    echo "2) n8n"
    echo "3) PostgreSQL"
    echo "4) Nginx"
    echo "5) Redis"
    echo "0) Back"
    echo ""
    read -p "Select option: " log_choice

    case $log_choice in
        1) docker-compose -f $COMPOSE_FILE logs --tail=100 -f ;;
        2) docker-compose -f $COMPOSE_FILE logs --tail=100 -f n8n ;;
        3) docker-compose -f $COMPOSE_FILE logs --tail=100 -f postgres ;;
        4) docker-compose -f $COMPOSE_FILE logs --tail=100 -f nginx ;;
        5) docker-compose -f $COMPOSE_FILE logs --tail=100 -f redis ;;
        0) return ;;
    esac
}

backup_now() {
    print_header
    echo -e "${YELLOW}Creating backup...${NC}"
    $PROJECT_DIR/scripts/backup.sh
    echo -e "${GREEN}✓ Backup completed${NC}"
    echo ""
    echo "Backups stored in: /backup/n8n/"
    ls -lh /backup/n8n/ | tail -5
    echo ""
    read -p "Press Enter to continue..."
}

update_system() {
    print_header
    echo -e "${YELLOW}Updating system...${NC}"

    # Backup first
    echo "Creating backup before update..."
    $PROJECT_DIR/scripts/backup.sh

    # Update Docker images
    cd $PROJECT_DIR
    docker-compose -f deployment/docker-compose.yml pull

    # Restart services
    docker-compose -f deployment/docker-compose.yml up -d

    echo -e "${GREEN}✓ System updated${NC}"
    sleep 2
}

view_resources() {
    print_header
    echo -e "${YELLOW}System Resources:${NC}"
    echo ""
    echo -e "${BLUE}Docker Containers:${NC}"
    docker stats --no-stream
    echo ""
    echo -e "${BLUE}Disk Usage:${NC}"
    df -h | grep -E "^/dev|Filesystem"
    echo ""
    echo -e "${BLUE}Memory Usage:${NC}"
    free -h
    echo ""
    read -p "Press Enter to continue..."
}

check_webhook() {
    print_header
    echo -e "${YELLOW}Checking Telegram Bot Webhook...${NC}"

    # Load bot token from .env
    if [ -f "$PROJECT_DIR/deployment/.env" ]; then
        source $PROJECT_DIR/deployment/.env
        if [ -n "$TELEGRAM_BOT_TOKEN" ]; then
            response=$(curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/getWebhookInfo")
            echo "$response" | python3 -m json.tool
        else
            echo -e "${RED}Bot token not found in .env file${NC}"
        fi
    else
        echo -e "${RED}.env file not found${NC}"
    fi
    echo ""
    read -p "Press Enter to continue..."
}

ssl_status() {
    print_header
    echo -e "${YELLOW}SSL Certificate Status:${NC}"

    # Get domain from nginx config
    DOMAIN=$(grep server_name $PROJECT_DIR/nginx/conf.d/n8n.conf | head -1 | awk '{print $2}' | sed 's/;//')

    if [ -n "$DOMAIN" ] && [ "$DOMAIN" != "your-domain.com" ]; then
        echo "Domain: $DOMAIN"
        echo ""
        # Check certificate expiry
        if [ -f "$PROJECT_DIR/certbot/conf/live/$DOMAIN/fullchain.pem" ]; then
            expiry=$(openssl x509 -enddate -noout -in "$PROJECT_DIR/certbot/conf/live/$DOMAIN/fullchain.pem" | cut -d= -f2)
            echo "Certificate expires: $expiry"

            # Check if needs renewal (within 30 days)
            expiry_epoch=$(date -d "$expiry" +%s)
            current_epoch=$(date +%s)
            days_left=$(( ($expiry_epoch - $current_epoch) / 86400 ))

            echo "Days until expiry: $days_left"

            if [ $days_left -lt 30 ]; then
                echo -e "${YELLOW}Certificate needs renewal soon!${NC}"
            else
                echo -e "${GREEN}Certificate is valid${NC}"
            fi
        else
            echo -e "${RED}Certificate not found${NC}"
        fi
    else
        echo -e "${RED}Domain not configured${NC}"
    fi
    echo ""
    read -p "Press Enter to continue..."
}

db_shell() {
    print_header
    echo -e "${YELLOW}Connecting to PostgreSQL...${NC}"
    echo "Type \\q to exit"
    echo ""
    cd $PROJECT_DIR
    docker-compose -f deployment/docker-compose.yml exec postgres psql -U n8n n8n
}

# Main loop
while true; do
    print_header
    print_menu
    read -p "Select option: " choice

    case $choice in
        1) view_status ;;
        2) start_services ;;
        3) stop_services ;;
        4) restart_services ;;
        5) view_logs ;;
        6) backup_now ;;
        7) update_system ;;
        8) view_resources ;;
        9) check_webhook ;;
        10) ssl_status ;;
        11) db_shell ;;
        0) echo "Goodbye!"; exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 1 ;;
    esac
done
