#!/bin/bash

# Import the InfluxData repository key and add it to your system
curl --silent --location -O \
https://repos.influxdata.com/influxdata-archive.key \
&& echo "943666881a1b8d9b849b74caebf02d3465d6beb716510d86a39f6c8e8dac7515  influxdata-archive.key" \
| sha256sum -c - && cat influxdata-archive.key \
| gpg --dearmor \
| sudo tee /etc/apt/trusted.gpg.d/influxdata-archive.gpg > /dev/null \
&& echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' \
| sudo tee /etc/apt/sources.list.d/influxdata.list

# Update package lists and install telegraf
sudo apt-get update && sudo apt-get install -y telegraf

# Copy telegraf configuration files
sudo tee /etc/default/telegraf > /dev/null <<EOF
influx_token=$influx_token
influx_bucket=$influx_bucket
influx_org=$influx_org
influx_server=$influx_server
influx_port=$influx_port
EOF
sudo cp ./config/telegraf.conf /etc/telegraf/telegraf.conf

# Start and enable telegraf service
sudo systemctl enable telegraf
sudo systemctl start telegraf
