#!/bin/bash
set -euxo pipefail

exec > >(tee -a /var/log/user-data.log) 2>&1

# Create a non-root administrator with passwordless sudo.
useradd --create-home --shell /bin/bash --groups wheel appadmin
echo "appadmin ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/appadmin
chmod 0440 /etc/sudoers.d/appadmin
visudo -cf /etc/sudoers.d/appadmin

# Install Docker and the host firewall.
yum update -y
yum install -y docker firewalld git
systemctl enable --now docker
systemctl enable --now firewalld

# Permit only SSH and the application's actual port at the host firewall.
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-port=5000/tcp
firewall-cmd --reload

# Fetch the challenge repository and build the actual Task 1 application.
mkdir -p /opt/intern-task-app
git clone --branch intern-task-app-solution --depth 1 https://github.com/JoshOgola/devops-challenge.git /opt/challenge
cd /opt/challenge/intern-task-app
docker build -t intern-task-app:local .

# Create a systemd service to manage the application container.
cat > /etc/systemd/system/intern-task-app.service <<'EOF'
[Unit]
Description=Task 1 application container
Requires=docker.service
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=simple
Restart=always
RestartSec=5
ExecStartPre=-/usr/bin/docker rm -f intern-task-app
ExecStart=/usr/bin/docker run --rm --name intern-task-app -p 5000:5000 intern-task-app:local
ExecStop=/usr/bin/docker stop --time 10 intern-task-app
ExecStopPost=-/usr/bin/docker rm -f intern-task-app

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable/start the service immediately.
systemctl daemon-reload
systemctl enable --now intern-task-app.service
