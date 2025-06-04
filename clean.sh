#!/bin/bash
SECONDS=0

# Check for root access
if [[ $EUID -ne 0 ]]; then
    echo "This script requires root privileges. Please enter your password."
    sudo -v
fi

# Ask before deleting saved Wi-Fi networks
read -p "Delete saved Wi-Fi networks (except home/work)? (y/N): " confirm_ssid
if [[ $confirm_ssid =~ ^[Yy]$ ]]; then
    homessid="MyHome"
    workssid="MyWork"
    echo "Deleting saved Wi-Fi networks except '$homessid' and '$workssid'..."
    IFS=$'\n'
    for ssid in $(networksetup -listpreferredwirelessnetworks en0 | grep -v "Preferred networks" | grep -v $homessid | grep -v $workssid | sed 's/[\t]*//g'); do
        echo "Removing SSID: $ssid"
        networksetup -removepreferredwirelessnetwork en0 "$ssid"
    done
fi

# Ask before installing updates
read -p "Install macOS software updates? (y/N): " confirm_update
if [[ $confirm_update =~ ^[Yy]$ ]]; then
    echo "Installing software updates..."
    softwareupdate -i -a
fi

# Ask before emptying trash
read -p "Empty the trash? (y/N): " confirm_trash
if [[ $confirm_trash =~ ^[Yy]$ ]]; then
    echo "Emptying user trash..."
    rm -rf ~/.Trash/*
    echo "Emptying volume trashes..."
    rm -rf /Volumes/*/.Trashes 2>/dev/null
fi

# Ask before deleting logs
read -p "Delete system logs and cache? (y/N): " confirm_logs
if [[ $confirm_logs =~ ^[Yy]$ ]]; then
    echo "Cleaning system logs..."
    rm -rf /private/var/log/*
    rm -rf /Library/Logs/DiagnosticReports/*
    echo "Deleting QuickLook cache..."
    rm -rf /private/var/folders/*
fi

# Ask before cleaning Homebrew
read -p "Clean up Homebrew? (y/N): " confirm_brew
if [[ $confirm_brew =~ ^[Yy]$ ]]; then
    echo "Cleaning Homebrew..."
    brew cleanup --prune=all
    rm -rf /Library/Caches/Homebrew/*
    brew tap --repair
    brew update
    brew upgrade
fi

# Ask before cleaning Ruby gems
read -p "Clean up Ruby gems? (y/N): " confirm_ruby
if [[ $confirm_ruby =~ ^[Yy]$ ]]; then
    echo "Cleaning up Ruby gems..."
    gem cleanup
fi

# Ask before cleaning Docker images
read -p "Remove unused Docker images? (y/N): " confirm_docker
if [[ $confirm_docker =~ ^[Yy]$ ]]; then
    echo "Removing dangling Docker images..."
    docker image prune -f
fi

# Ask before removing SSH known_hosts
read -p "Delete known SSH hosts? (y/N): " confirm_ssh
if [[ $confirm_ssh =~ ^[Yy]$ ]]; then
    echo "Removing known SSH hosts..."
    rm -f ~/.ssh/known_hosts
fi

# Ask before purging memory
if command -v purge &> /dev/null; then
    read -p "Purge system memory? (y/N): " confirm_purge
    if [[ $confirm_purge =~ ^[Yy]$ ]]; then
        echo "Purging memory..."
        sudo purge
    fi
else
    echo "Skipping purge (not available on this system)"
fi

# Done
elapsed="$((SECONDS / 60)) minutes and $((SECONDS % 60)) seconds"
echo "✅ Maintenance complete. Time taken: $elapsed"
