#!/bin/bash

sudo apt-get install -y apt-transport-https software-properties-common wget

# Import GPG Key
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

# Add stable releases repo
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

# Updates the list of available packages
sudo apt-get update

# Installs the latest OSS release:
sudo apt-get install -y grafana

# Create and copy configuration files
sudo tee /etc/grafana/provisioning/datasources/influx_datasource.yaml > /dev/null <<EOF
apiVersion: 1

datasources:
  - name: influxdb
    type: influxdb
    access: proxy
    orgId: 1
    uid: 10001
    url: http://localhost:$influx_port
    jsonData:
      version: Flux
      organization: $influx_org
      defaultBucket: $influx_bucket
      #tlsSkipVerify: true
    secureJsonData:
      token: $influx_token
    editable: true
EOF

sudo cp ./server/pi_provider.yaml  /etc/grafana/provisioning/dashboards/pi_provider.yaml
sudo mkdir -p /var/lib/grafana/dashboards
sudo cp ./server/pi_metrics.json  /var/lib/grafana/dashboards/pi_metrics.json

sudo systemctl daemon-reload
sudo systemctl enable grafana-server

sudo sed -i "/admin_user/s/.*/admin_user = $user/" /etc/grafana/grafana.ini
sudo sed -i "/http_port/s/.*/http_port = $grafana_port/" /etc/grafana/grafana.ini
sudo sed -i "/default_home_dashboard_path/s/.*/default_home_dashboard_path = \/var\/lib\/grafana\/dashboards\/pi_metrics.json/" /etc/grafana/grafana.ini

sudo systemctl restart grafana-server
