#!/bin/bash

# Email configuration
ADMIN_EMAIL="admin@example.com"
SUBJECT="SSH Brute Force Attack Detected"
BODY="A brute force attack was detected from IP: $1. The IP has been blocked."

# Use mail command to send email (install with apt-get install mailutils)
echo "$BODY" | mail -s "$SUBJECT" $ADMIN_EMAIL
