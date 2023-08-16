#!/bin/bash
if sudo nginx -t; then
    echo "Nginx configuration test successful."
else
    echo "Nginx configuration test failed. Script will exit."
    exit 1
fi

sudo systemctl reload nginx

echo "Nginx configuration reloaded successfully."

