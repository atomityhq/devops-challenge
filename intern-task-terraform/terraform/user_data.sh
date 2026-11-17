#!/bin/bash
set -euxo pipefail

apt-get update -y
apt-get install -y docker.io ufw git

systemctl enable --now docker

# Create non-root administration user
if ! id devops >/dev/null 2>&1; then
    useradd --create-home --shell /bin/bash devops
fi

usermod -aG sudo,docker devops
echo "devops ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/devops
chmod 0440 /etc/sudoers.d/devops

# Host firewall
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow from "${ssh_cidr}" to any port 22 proto tcp
ufw allow "${app_port}/tcp"
ufw --force enable

# Clone the submitted application from your GitHub fork
git clone --depth 1 https://github.com/labidi-houssem/devops-challenge.git /tmp/devops-challenge

mkdir -p /opt/intern-task-app
cp -r /tmp/devops-challenge/intern-task-app/. /opt/intern-task-app/

# Build the actual application Dockerfile
docker build -t intern-task-app:latest /opt/intern-task-app

# Systemd-managed application container
cat > /etc/systemd/system/intern-task-app.service <<SERVICE
[Unit]
Description=Atomity Intern Task Application
Requires=docker.service
After=docker.service network-online.target
Wants=network-online.target

[Service]
Restart=always
RestartSec=5
ExecStartPre=-/usr/bin/docker rm -f intern-task-app
ExecStart=/usr/bin/docker run --rm --name intern-task-app --network host -e PORT=${app_port} intern-task-app:latest
ExecStop=/usr/bin/docker stop intern-task-app

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable --now intern-task-app.service
