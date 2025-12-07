#!/bin/bash

# ----------------------------
# Configure Vault (non-dev, no TLS) and set up systemd
# ----------------------------

VAULT_USER=vault
VAULT_USER=vault
VAULT_CONFIG_DIR="/etc/vault"
VAULT_DATA_DIR="/opt/vault/data"
VAULT_SERVICE="/etc/systemd/system/vault.service"

# 1. Create Vault user if not exists
if ! id -u $VAULT_USER >/dev/null 2>&1; then
    sudo useradd --system --home $VAULT_DATA_DIR --shell /bin/false $VAULT_USER
fi

# 2. Create Vault config & data directories
sudo mkdir -p $VAULT_CONFIG_DIR
sudo mkdir -p $VAULT_DATA_DIR
sudo chown -R $VAULT_USER:$VAULT_USER $VAULT_DATA_DIR

# 3. Create Vault configuration file
sudo tee $VAULT_CONFIG_DIR/config.hcl > /dev/null <<EOF
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

storage "file" {
  path = "$VAULT_DATA_DIR"
}

ui = true
EOF

sudo chown $VAULT_USER:$VAULT_USER $VAULT_CONFIG_DIR/config.hcl
sudo chmod 640 $VAULT_CONFIG_DIR/config.hcl

# 4. Create systemd service
sudo tee $VAULT_SERVICE > /dev/null <<EOF
[Unit]
Description=HashiCorp Vault - Secret Management
Requires=network-online.target
After=network-online.target

[Service]
User=$VAULT_USER
Group=$VAULT_USER
ExecStart=/usr/local/bin/vault server -config=$VAULT_CONFIG_DIR/config.hcl
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# 5. Reload systemd and start Vault
sudo systemctl daemon-reload
sudo systemctl enable vault
sudo systemctl start vault

# 6. Check Vault status
sleep 2
sudo systemctl status vault --no-pager

echo ""
echo "Vault is now running in non-dev mode without TLS."
echo "Access the UI at: http://<your-server-ip>:8200/ui"
echo "Initialize Vault with: vault operator init"
