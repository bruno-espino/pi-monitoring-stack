#!/bin/bash

echo "Waiting till Grafana starts up..."
sleep 30

if systemctl is-active --quiet grafana-server; then
    sudo grafana-cli admin reset-admin-password $password
else
    echo "Grafana isn't active. Password can't be changed."
fi