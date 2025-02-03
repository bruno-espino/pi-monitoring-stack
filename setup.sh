#!/bin/bash

# Set env variables
admin_pwd_len=$(cat ./config/variables.sh | grep password | awk -F '=' '{print $2}' | tr -d '\n' | wc -m)

if [[ $admin_pwd_len -le 11 ]]; then
    echo "Admin password must have at least 9 chars."
    echo "Edit './config/variables.sh' file."
    exit 1
else
    source ./config/variables.sh
    
    grafana_free_port=$(sudo netstat -plnt | grep ":$grafana_port" | awk '{print $7}')
    if [[ "${#grafana_free_port}" -gt 0 ]]; then
        echo "The port $grafana_port assigned to Grafana is already in use by: $grafana_free_port (PID/Program name)"
    fi

    infulx_free_port=$(sudo netstat -plnt | grep ":$influx_port" | awk '{print $7}')
    if [[ "${#infulx_free_port}" -gt 0 ]]; then
        echo "The port $influx_port assigned to InfluxDB is already in use by: $infulx_free_port (PID/Program name)"
    fi

    if [[ "${#infulx_free_port}" -gt 0 ]] || [[ "${#grafana_free_port}" -gt 0 ]]; then
        read -p "Do you want to continue anyway? (y/N)" -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]
        then
            [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
        fi
    fi
    
    echo "Installing dependencies"
    sudo apt-get install -y wget gpg curl

if [[ $admin_pwd_len -lt 10 ]]; then
    echo "Admin password must have at least 8 chars"
    exit 1
else
    source ./config/variables.sh

fi

show_menu() {
    echo
    echo "Select Agent or Server setup"
    echo "1) Agent"
    echo "2) Server"
    echo ""
    echo "3) Exit"
    echo ""
    echo "9) Nuke it"
    echo
}

# Run scripts
run_scripts () {
    folder=$1
    if [ -d "$folder" ]; then
        for script in "$folder"/*.sh; do
            echo
            echo "Running $script"
            echo
            bash "$script"
        done
    else
        echo "Folder $folder does not exist"
    fi
}

# Main Menu
while true; do
    show_menu
    read -p "Enter your choices: " -a choices

    if [[ " ${choices[@]} " =~ " 3 " ]]; then
        echo "Exiting..."
        break
    fi

    for choice in "${choices[@]}"; do
        case $choice in
            1) 
                echo "Running Agent setup"
                run_scripts "agent"
                ;;
            2)
                echo "Running Server setup"
                run_scripts "server"
                ;;
            9)
                echo "Uninstalling and removing all assets"
                run_scripts "remove"
                ;;
            *)
                echo "Invalid option"
                ;;
        esac
    done
done
