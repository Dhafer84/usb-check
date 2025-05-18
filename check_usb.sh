#!/bin/bash

echo "🔁 Surveillance des clés USB + port USB utilisé..."
previous_devices=""

while true; do
    current_devices=""
    output=""

    for dev in $(lsblk -o NAME,RM -nr | awk '$2 == 1 {print $1}' | sort); do
        # Obtenir le chemin du device
        sys_path="/sys/block/$dev"
        
        # Vérifier si c'est bien un périphérique USB
        if [[ -L "$sys_path" ]]; then
            usb_path=$(readlink -f "$sys_path" | grep -o '/usb[0-9]/[0-9]-[0-9:]*' || true)
            if [[ -n "$usb_path" ]]; then
                port_info=$(basename "$usb_path")
                current_devices+="$dev@$port_info "
                output+="✅ Clé détectée : /dev/$dev sur port USB $port_info\n"
            fi
        fi
    done

    if [[ "$current_devices" != "$previous_devices" ]]; then
        timestamp=$(date '+%H:%M:%S')
        if [[ -z "$current_devices" ]]; then
            echo "[$timestamp] ❌ Aucune clé USB détectée"
        else
            echo -e "[$timestamp] $output"
        fi
        previous_devices="$current_devices"
    fi

    sleep 2
done

