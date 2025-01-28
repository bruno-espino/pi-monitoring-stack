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

# sudo sed -i "/disable_initial_admin_creation/s/.*/disable_initial_admin_creation = true/" /etc/grafana/grafana.ini
# sudo sed -i "/admin_user/s/.*/admin_user = $user/" /etc/grafana/grafana.ini
# sudo sed -i "/admin_password/s/.*/admin_password = admin/" /etc/grafana/grafana.ini
sudo sed -i "/http_port/s/.*/http_port = $grafana_port/" /etc/grafana/grafana.ini
sudo sed -i "/default_home_dashboard_path/s/.*/default_home_dashboard_path = \/var\/lib\/grafana\/dashboards\/pi_metrics.json/" /etc/grafana/grafana.ini

pip install bcrypt
HASHED_PASSWORD=$(python3 -c "import bcrypt; print(bcrypt.hashpw(b'$password', bcrypt.gensalt()).decode())")  # Generar la contraseña hasheada con bcrypt

sudo sqlite3 /var/lib/grafana/grafana.db <<EOF
INSERT INTO user (login, email, password, isActive, created, updated)
VALUES ('$user', 'admin@example.com', '$HASHED_PASSWORD', 1, datetime('now'), datetime('now'));
EOF

sqlite3 $GRAFANA_DB_PATH <<EOF
INSERT INTO org_role (user_id, org_id, role)
VALUES (1, 1, 'Admin');
EOF

sudo systemctl restart grafana-server

# sudo grafana-cli admin reset-admin-password $password
