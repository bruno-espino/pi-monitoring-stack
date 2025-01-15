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
sudo apt-get update && sudo apt-get install telegraf

# Copy configuration files
sudo cp ./config/telegraf  /etc/default/telegraf
sudo cp ./config/telegraf_agent.conf /etc/telegraf/telegraf.conf

# Start and enable telegraf service
sudo systemctl enable telegraf
sudo systemctl start telegraf