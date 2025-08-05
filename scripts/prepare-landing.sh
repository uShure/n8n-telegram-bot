#!/bin/bash

# Prepare landing page for deployment
# This script builds the landing page for production

set -e

echo "Preparing landing page for deployment..."

# Create landing directory
mkdir -p ../deployment/landing

# Copy HTML
cp ../index.html ../deployment/landing/

# Build CSS and JS
cd ..
bun run build

# Copy built assets
cp -r dist/* deployment/landing/

# Copy static assets if any
if [ -d "public" ]; then
    cp -r public/* deployment/landing/
fi

# Create a simple nginx config for serving landing
cat > deployment/landing/nginx-landing.conf << 'EOF'
location = / {
    root /var/www/landing;
    try_files /index.html =404;
}

location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg)$ {
    root /var/www/landing;
    expires 1y;
    add_header Cache-Control "public, immutable";
}
EOF

echo "Landing page prepared in deployment/landing/"
echo "Files will be served from the root domain"
