show_menu() {
    echo
    echo "Select Agent or Server to remove"
    echo "1) Agent"
    echo "2) Server"
    echo "3) Back"
    echo
}


# Main Menu
while true; do
    show_menu
    read -p "Enter your choices: " -a choices

    # if [[ " ${choices[@]} " =~ " 3 " ]]; then
    #     echo "Exiting..."
    #     break
    # fi

    for choice in "${choices[@]}"; do
        case $choice in
            1) 
                echo "Rmove Agent setup"
                remove_agent
                ;;
            2)
                echo "Remove Server setup"
                remove_server
                ;;
            3)
                echo "Back"
                bash ../setup.sh
                ;;
            *)
                echo "Invalid option"
                ;;
        esac
    done
done

remove_agent(){
    sudo systemctl stop telegraf.service
    sudo apt-get remove -y telegraf
    sudo rm -rf /var/lib/telegraf /etc/telegraf
}

remove_server(){
    sudo systemctl stop influxd.service grafana-server.service telegraf.service
    sudo apt-get remove -y telegraf influxdb2 grafana

    sudo rm -rf /var/lib/influxdb /var/log/influxdb
    sudo rm -rf /var/lib/telegraf /etc/telegraf
    sudo rm -rf /var/lib/grafana /etc/grafana /var/log/grafana 
}