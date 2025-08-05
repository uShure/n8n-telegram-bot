#!/bin/bash

# Start Demo Script for n8n Telegram Bot
# This script starts a demo version with mock APIs and real Telegram bot

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🚀 Starting n8n Telegram Bot Demo...${NC}"
echo ""

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed. Please install Docker Compose first.${NC}"
    exit 1
fi

# Create necessary directories
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p landing workflows credentials

# Copy demo env file
if [ ! -f "../demo-env-config.txt" ]; then
    echo -e "${RED}Demo environment file not found!${NC}"
    exit 1
fi

echo -e "${YELLOW}Setting up environment...${NC}"
cp ../demo-env-config.txt .env

# Start services
echo -e "${YELLOW}Starting Docker containers...${NC}"
docker-compose -f ../docker-compose.demo.yml up -d

# Wait for services to start
echo -e "${YELLOW}Waiting for services to start...${NC}"
sleep 10

# Check services status
echo -e "${YELLOW}Checking services...${NC}"
docker-compose -f ../docker-compose.demo.yml ps

echo ""
echo -e "${GREEN}✅ Demo started successfully!${NC}"
echo ""
echo -e "${YELLOW}Access URLs:${NC}"
echo -e "  n8n Interface: ${GREEN}http://localhost:5678${NC}"
echo -e "  Landing Page: ${GREEN}http://localhost:8080${NC}"
echo -e "  Mock API: ${GREEN}http://localhost:3001/health${NC}"
echo ""
echo -e "${YELLOW}Login Credentials:${NC}"
echo -e "  Username: ${GREEN}demo${NC}"
echo -e "  Password: ${GREEN}demo123${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Open n8n at http://localhost:5678"
echo "2. Import workflow from demo/workflows/telegram-bot-demo.json"
echo "3. Configure Telegram credentials with token from .env"
echo "4. Activate the workflow"
echo "5. Test the bot in Telegram"
echo ""
echo -e "${YELLOW}Bot Username:${NC} Search for your bot in Telegram using the token"
echo ""
echo -e "${RED}⚠️  This is a DEMO version. Do not use in production!${NC}"
echo ""
echo -e "To stop the demo: ${YELLOW}docker-compose -f ../docker-compose.demo.yml down${NC}"
