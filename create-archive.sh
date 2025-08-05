#!/bin/bash

# Create archive for client delivery

echo "Creating project archive..."

# Archive name with date
ARCHIVE_NAME="n8n-telegram-bot-$(date +%Y%m%d).tar.gz"

# Files to include
tar -czf $ARCHIVE_NAME \
  --exclude='.git' \
  --exclude='node_modules' \
  --exclude='*.log' \
  --exclude='.env' \
  --exclude='dist' \
  --exclude='.same' \
  workflows/ \
  prompts/ \
  docs/ \
  config/ \
  deployment/ \
  nginx/ \
  scripts/ \
  src/ \
  index.html \
  package.json \
  README.md \
  create-archive.sh

echo "Archive created: $ARCHIVE_NAME"
echo "Size: $(du -h $ARCHIVE_NAME | cut -f1)"
echo ""
echo "Archive contents:"
tar -tzf $ARCHIVE_NAME | head -20
echo "..."
echo ""
echo "Ready to send to client!"
