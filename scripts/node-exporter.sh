VERSION=1.8.2
wget https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.linux-amd64.tar.gz
tar zxvf node_exporter-${VERSION}.linux-amd64.tar.gz
cd node_exporter-${VERSION}.linux-amd64
cp node_exporter /usr/local/bin/
useradd --no-create-home --shell /bin/false nodeusr
chown -R nodeusr:nodeusr /usr/local/bin/node_exporter
tee /etc/systemd/system/node_exporter.service<<EOF
[Unit]
Description=Node Exporter Service
After=network.target

[Service]
User=nodeusr
Group=nodeusr
Type=simple
ExecStart=/usr/local/bin/node_exporter
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter
