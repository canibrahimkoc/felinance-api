if ! systemctl status felinance &>/dev/null; then
    cd /opt/felinance-api
    dart pub get || true
    bash -c 'cat << EOF > /etc/systemd/system/felinance.service
[Unit]
Description=Felinance API Service
After=network.target

[Service]
User=root
WorkingDirectory=/opt/felinance-api
ExecStart=/bin/bash -c '\''cd /opt/felinance-api && python3.11 -m venv venv && source /opt/felinance-api/venv/bin/activate && python3.11 -m pip install -r requirements.txt -U && dart run server.dart && deactivate'\'' 
Environment="PATH=/usr/bin:/opt/felinance-api/venv/bin"
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF'
    systemctl daemon-reload || true
    systemctl enable --now felinance.service || true
else
    echo "API is already installed."
fi
