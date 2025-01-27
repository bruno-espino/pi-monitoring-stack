#!/bin/bash

# Set env variables
admin_pwd_len=$(cat ./config/variables.sh | grep password | awk -F '=' '{print $2}' | tr -d '\n' | wc -m)
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
    echo "3) Exit"
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
            *)
                echo "Invalid option"
                ;;
        esac
    done
done
