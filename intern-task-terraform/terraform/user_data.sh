#!/bin/bash
set -euxo pipefail

APP_USER="devops"
APP_DIR="/opt/intern-task-app"
APP_PORT="8080"
SSH_CIDR="${ssh_cidr}"

# Create a non-root user with passwordless sudo
useradd --create-home --shell /bin/bash "$APP_USER"
echo "$APP_USER ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$APP_USER"
chmod 0440 "/etc/sudoers.d/$APP_USER"

# Install Docker and firewall tools
dnf update -y
dnf install -y docker firewalld

systemctl enable --now docker
systemctl enable --now firewalld

# Configure host firewall
firewall-cmd --permanent --zone=public --remove-service=ssh || true
firewall-cmd --permanent --zone=public --set-target=DROP
firewall-cmd --permanent --zone=public --add-port="$${APP_PORT}/tcp"

# Allow SSH only from the administrator CIDR
firewall-cmd --permanent --zone=public \
  --add-rich-rule="rule family=ipv4 source address=$${SSH_CIDR} port port=22 protocol=tcp accept"

firewall-cmd --reload

# Download the actual Task 1 application
mkdir -p "$APP_DIR/app"

curl -fsSL \
  https://raw.githubusercontent.com/SkyInfra/devops-challenge/feat/containerize-kubernetes-app/intern-task-app/Dockerfile \
  -o "$APP_DIR/Dockerfile"

curl -fsSL \
  https://raw.githubusercontent.com/SkyInfra/devops-challenge/feat/containerize-kubernetes-app/intern-task-app/app/app.py \
  -o "$APP_DIR/app/app.py"

# Build the application Docker image
docker build -t intern-task-app:local "$APP_DIR"

# Configure systemd service
cat > /etc/systemd/system/intern-task-app.service <<'SERVICE'
[Unit]
Description=Intern Task Application Container
Requires=docker.service
After=docker.service

[Service]
Restart=always
RestartSec=5
ExecStartPre=-/usr/bin/docker rm -f intern-task-app
ExecStart=/usr/bin/docker run --name intern-task-app --restart=no -p 8080:8080 -e PORT=8080 intern-task-app:local
ExecStop=/usr/bin/docker stop intern-task-app

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable --now intern-task-app.service
