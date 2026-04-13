#!/usr/bin/env bash

# WiFi menu for Waybar using rofi
# Uses nmcli for network management

DIR="$HOME/.config/waybar/scripts"
THEME="$DIR/wifi-menu.rasi"

# Get current connection info
get_status() {
    WIFI_STATE=$(nmcli -fields WIFI g | tail -n 1 | tr -d ' ')
    if [[ "$WIFI_STATE" == "enabled" ]]; then
        CURRENT=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
        if [[ -n "$CURRENT" ]]; then
            SIGNAL=$(nmcli -t -f active,signal dev wifi | grep '^yes' | cut -d: -f2)
            echo "Connected to $CURRENT ($SIGNAL%)"
        else
            echo "WiFi enabled - Not connected"
        fi
    else
        echo "WiFi disabled"
    fi
}

# Signal strength to icon
signal_icon() {
    local signal=$1
    if [[ $signal -ge 80 ]]; then
        echo "󰤨"
    elif [[ $signal -ge 60 ]]; then
        echo "󰤥"
    elif [[ $signal -ge 40 ]]; then
        echo "󰤢"
    elif [[ $signal -ge 20 ]]; then
        echo "󰤟"
    else
        echo "󰤯"
    fi
}

# Build network list
get_networks() {
    # Rescan networks
    nmcli dev wifi rescan 2>/dev/null
    sleep 0.5

    CURRENT=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)

    # Get networks: SSID, SIGNAL, SECURITY
    nmcli -t -f ssid,signal,security dev wifi list | while IFS=: read -r ssid signal security; do
        [[ -z "$ssid" ]] && continue

        icon=$(signal_icon "$signal")

        # Mark current network
        if [[ "$ssid" == "$CURRENT" ]]; then
            echo "$icon  $ssid  [$signal%]  *"
        else
            if [[ "$security" == "--" ]] || [[ -z "$security" ]]; then
                echo "$icon  $ssid  [$signal%]  󰿡"
            else
                echo "$icon  $ssid  [$signal%]  󰌾"
            fi
        fi
    done | sort -t'[' -k2 -rn | uniq
}

# Toggle WiFi
toggle_wifi() {
    WIFI_STATE=$(nmcli -fields WIFI g | tail -n 1 | tr -d ' ')
    if [[ "$WIFI_STATE" == "enabled" ]]; then
        nmcli radio wifi off
        notify-send "WiFi" "Disabled" -i network-wireless-offline
    else
        nmcli radio wifi on
        notify-send "WiFi" "Enabled" -i network-wireless
    fi
}

# Connect to network
connect() {
    local ssid="$1"

    # Check if it's a known network
    if nmcli -t -f name connection show | grep -qx "$ssid"; then
        nmcli connection up "$ssid" && \
            notify-send "WiFi" "Connected to $ssid" -i network-wireless || \
            notify-send "WiFi" "Failed to connect to $ssid" -i network-wireless-offline
    else
        # Need password
        PASSWORD=$(rofi -dmenu -p "Password" -password -theme "$THEME" -mesg "Enter password for $ssid")
        if [[ -n "$PASSWORD" ]]; then
            nmcli dev wifi connect "$ssid" password "$PASSWORD" && \
                notify-send "WiFi" "Connected to $ssid" -i network-wireless || \
                notify-send "WiFi" "Failed to connect to $ssid" -i network-wireless-offline
        fi
    fi
}

# Main menu
main() {
    STATUS=$(get_status)
    WIFI_STATE=$(nmcli -fields WIFI g | tail -n 1 | tr -d ' ')

    if [[ "$WIFI_STATE" == "enabled" ]]; then
        TOGGLE="󰤮  Disable WiFi"
        NETWORKS=$(get_networks)
        OPTIONS="$TOGGLE\n󰑓  Refresh\n$NETWORKS"
    else
        TOGGLE="󰤨  Enable WiFi"
        OPTIONS="$TOGGLE"
    fi

    CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "WiFi" -theme "$THEME" -mesg "$STATUS" -i)

    case "$CHOICE" in
        "󰤮  Disable WiFi"|"󰤨  Enable WiFi")
            toggle_wifi
            ;;
        "󰑓  Refresh")
            main
            ;;
        *)
            if [[ -n "$CHOICE" ]]; then
                # Extract SSID (between first double space and second double space)
                SSID=$(echo "$CHOICE" | sed 's/^[^ ]*  //' | sed 's/  \[.*//')
                connect "$SSID"
            fi
            ;;
    esac
}

main
