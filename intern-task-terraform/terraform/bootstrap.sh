#!/bin/bash
set -euo pipefail

# Create a non-root user with passwordless sudo.
if ! id deployer >/dev/null 2>&1; then
  useradd -m -s /bin/bash deployer
fi

echo "deployer ALL=(ALL) NOPASSWD:ALL" \
  > /etc/sudoers.d/deployer
chmod 0440 /etc/sudoers.d/deployer

# Install Docker and the host firewall.
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y docker.io ufw

# Start Docker now and automatically after reboot.
systemctl enable --now docker

# Recreate the actual application files supplied by Terraform.
mkdir -p /opt/intern-task-app/app

base64 -d > /opt/intern-task-app/Dockerfile <<'DOCKERFILE'
${dockerfile_b64}
DOCKERFILE

base64 -d > /opt/intern-task-app/app/app.py <<'APP'
${app_b64}
APP

# Build the real application using its existing Dockerfile.
docker build -t intern-task-app:local /opt/intern-task-app

# Configure the host firewall.
# Deny unsolicited incoming traffic by default.
ufw default deny incoming
ufw default allow outgoing

# Permit SSH only from the trusted CIDR.
ufw allow from ${ssh_cidr} to any port 22 proto tcp

# Permit public access to the Python application.
ufw allow 8080/tcp
ufw --force enable

# Create a systemd service to manage the Docker container.
cat > /etc/systemd/system/intern-task-app.service <<'SERVICE'
[Unit]
Description=Intern Task App Docker Container
Requires=docker.service
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStartPre=-/usr/bin/docker rm -f intern-task-app
ExecStart=/usr/bin/docker run --name intern-task-app --network host --env PORT=8080 intern-task-app:local
ExecStop=/usr/bin/docker stop intern-task-app
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE

# Register, enable, and immediately start the application service.
systemctl daemon-reload
systemctl enable --now intern-task-app.service
