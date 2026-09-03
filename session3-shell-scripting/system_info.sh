#!/bin/bash

# Get user input
read -p "Enter a directory name to create: " dirname

# Create directory
mkdir -p "$dirname"

# Create a file inside the directory
touch "$dirname/info.txt"

# Store system information in variables
current_date=$(date)
hostname=$(hostname)
username=$(whoami)

# Display system information
echo "=================================="
echo "       SYSTEM INFORMATION"
echo "=================================="

echo "Current Date : $current_date"
echo "Hostname     : $hostname"
echo "Username     : $username"

echo ""
echo "Disk Usage:"
df -h

echo ""
echo "Running Processes:"
ps

# Save process information to a file
ps > "$dirname/processes.txt"

echo ""
echo "Process information saved to $dirname/processes.txt"
echo "=================================="
