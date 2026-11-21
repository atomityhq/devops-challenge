#!/bin/bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y docker.io ufw

if ! id appadmin >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash appadmin
fi
echo "appadmin ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/appadmin
chmod 440 /etc/sudoers.d/appadmin
usermod -aG docker appadmin

systemctl enable --now docker

mkdir -p /opt/intern-task-app/app
echo '${dockerfile_base64}' | base64 --decode > /opt/intern-task-app/Dockerfile
echo '${app_source_base64}' | base64 --decode > /opt/intern-task-app/app/app.py

docker build -t intern-task-app:local /opt/intern-task-app

ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow from ${ssh_cidr} to any port 22 proto tcp
ufw allow ${app_port}/tcp
ufw --force enable

cat > /etc/systemd/system/intern-task-app.service <<'UNIT'
[Unit]
Description=intern-task-app container
Requires=docker.service
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=simple
Restart=always
RestartSec=5
ExecStartPre=-/usr/bin/docker rm -f intern-task-app
ExecStart=/usr/bin/docker run --rm --name intern-task-app -p ${app_port}:${app_port} -e PORT=${app_port} intern-task-app:local
ExecStop=/usr/bin/docker stop intern-task-app

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable --now intern-task-app.service
