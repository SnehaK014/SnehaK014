#!/bin/bash
#SNEHAKHATRIPROJECT
# Configuration
LOG_FILE="/var/log/auth.log"           # Log file to monitor
THRESHOLD=5                            # Failed attempts threshold
WHITELIST_FILE="./ip_whitelist.txt"    # File containing whitelisted IPs
DETECTED_IPS_LOG="./detected_ips.log"  # Log of detected IPs
BLOCKED_IPS_LOG="./iptables_blocked_ips.log" # Log of blocked IPs

# Check and create log files if not exist
touch $DETECTED_IPS_LOG $BLOCKED_IPS_LOG

# Function to block an IP using iptables
block_ip() {
    IP=$1
    echo "Blocking IP: $IP"
    iptables -A INPUT -s $IP -j DROP
    echo "$(date) - $IP blocked" >> $BLOCKED_IPS_LOG
}

# Function to check if IP is whitelisted
is_whitelisted() {
    IP=$1
    if grep -q "$IP" $WHITELIST_FILE; then
        return 0    # IP is whitelisted
    else
        return 1    # IP is not whitelisted
    fi
}
#SNEHAKHATRI PROJECT
# Function to send notification
send_notification() {
    IP=$1
    ./email_notification.sh "$IP"      # Call the email notification script
}

# Function to detect brute force attacks
#SNEHAKHATRIPROJECT
detect_brute_force() {
    grep "Failed password" $LOG_FILE | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr > $DETECTED_IPS_LOG
    
    # Check each IP's failed attempts
    while read attempt_count ip; do
        if [ $attempt_count -ge $THRESHOLD ]; then
            if ! is_whitelisted $ip; then
                # Check if the IP is already blocked
                iptables -L INPUT -v -n | grep -q $ip
                if [ $? -ne 0 ]; then
                    block_ip $ip
                    send_notification $ip
                else
                    echo "IP $ip is already blocked."
                fi
            else
                echo "IP $ip is whitelisted, not blocking."
            fi
        fi
    done < $DETECTED_IPS_LOG
}

# Schedule the script to run every minute
while true; do
    detect_brute_force
    sleep 60
done
