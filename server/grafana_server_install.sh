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
    url: http://$influx_server:$influx_port
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

# Start and enable grafana service
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl stop grafana-server

sudo sed -i "/http_port/s/.*/http_port = $grafana_port/" /etc/grafana/grafana.ini
sudo sed -i "/default_home_dashboard_path/s/.*/default_home_dashboard_path = \/var\/lib\/grafana\/dashboards\/pi_metrics.json/" /etc/grafana/grafana.ini

sudo sqlite3 /var/lib/grafana/grafana.db "UPDATE user SET login='$user' WHERE id='1';"

sudo systemctl restart grafana-server

sudo grafana-cli admin reset-admin-password $password

1|0|admin|admin@localhost||128f686e84581ce110443789b|m7LAGMr5XJ|SS3n9L9y2M||1|1|0||2025-01-29 03:29:53|2025-01-29 03:29:53|0|2015-01-29 02:29:53|0|0|debezl1ntm8zk
1|0|admin|admin@localhost||e728ec82cf71208dbaaf6f4ee|m7LAGMr5XJ|SS3n9L9y2M||1|1|0||2025-01-29 03:29:53|2025-01-29 03:54:04|0|2025-01-29 03:54:04|0|0|debezl1ntm8zkf

0|id|INTEGER|1||1                         1|
1|version|INTEGER|1||0                    0|
2|login|TEXT|1||0                         admin|
3|email|TEXT|1||0                         admin@localhost|
4|name|TEXT|0||0                          |
5|password|TEXT|0||0                      128f686e84581ce110443789b|
6|salt|TEXT|0||0                          m7LAGMr5XJ|
7|rands|TEXT|0||0                         SS3n9L9y2M|
8|company|TEXT|0||0                       |
9|org_id|INTEGER|1||0                     1|
10|is_admin|INTEGER|1||0                  1|            
11|email_verified|INTEGER|0||0            0|
12|theme|TEXT|0||0                        |
13|created|DATETIME|1||0                  2025-01-29 03:29:53|
14|updated|DATETIME|1||0                  2025-01-29 03:29:53|
15|help_flags1|INTEGER|1|0|0              0|
16|last_seen_at|DATETIME|0||0             2015-01-29 02:29:53|
17|is_disabled|INTEGER|1|0|0              0|
18|is_service_account|BOOLEAN|0|0|0       0|
19|uid|TEXT|0||0                          debezl1ntm8zk