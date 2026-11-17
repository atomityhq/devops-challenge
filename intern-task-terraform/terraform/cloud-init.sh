#!/bin/bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

# --------------------------------------------------
# 1. Create a non-root user with passwordless sudo
# --------------------------------------------------
if ! id -u appadmin >/dev/null 2>&1; then
  useradd -m -s /bin/bash appadmin
fi

echo 'appadmin ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/appadmin
chmod 0440 /etc/sudoers.d/appadmin

# --------------------------------------------------
# 2. Install Docker, Git, and firewall utilities
# --------------------------------------------------
apt-get update
apt-get install -y docker.io git ufw iptables

systemctl enable --now docker

# --------------------------------------------------
# 3. Configure the host firewall
# --------------------------------------------------
# UFW protects host INPUT traffic.
# SSH source restriction is enforced by the AWS
# security group, while UFW permits SSH on the host.
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 5000/tcp
ufw --force enable

# Docker-published ports traverse the FORWARD chain.
# DOCKER-USER filters traffic before Docker accepts it.
# Match the original destination port after Docker DNAT.
cat > /usr/local/sbin/intern-task-firewall.sh <<'FIREWALL'
#!/bin/bash
set -euo pipefail

# Create the chain if Docker has not created it yet.
iptables -N DOCKER-USER 2>/dev/null || true

# Ensure the FORWARD chain passes through DOCKER-USER.
iptables -C FORWARD -j DOCKER-USER 2>/dev/null ||
  iptables -I FORWARD 1 -j DOCKER-USER

# Apply only to traffic entering from outside Docker.
# Avoid interfering with container-originated traffic.
EXT_IF=$(ip -4 route show default | awk '{print $5; exit}')

if [ -z "$EXT_IF" ]; then
  echo "Cannot determine external network interface"
  exit 1
fi

# Rebuild our dedicated firewall chain.
iptables -N INTERN-TASK-FILTER 2>/dev/null || true
iptables -F INTERN-TASK-FILTER

# Allow established connections.
iptables -A INTERN-TASK-FILTER \
  -m conntrack --ctstate ESTABLISHED,RELATED -j RETURN

# Allow traffic originally addressed to TCP port 5000.
iptables -A INTERN-TASK-FILTER \
  -p tcp -m conntrack --ctdir ORIGINAL \
  --ctorigdstport 5000 -j RETURN

# Block other new inbound forwarded connections.
iptables -A INTERN-TASK-FILTER -j DROP

# Insert our filter once, for external traffic only.
iptables -C DOCKER-USER -i "$EXT_IF" \
  -j INTERN-TASK-FILTER 2>/dev/null ||
  iptables -I DOCKER-USER 1 -i "$EXT_IF" \
  -j INTERN-TASK-FILTER
FIREWALL

chmod 0755 /usr/local/sbin/intern-task-firewall.sh

# Reapply firewall rules after Docker starts on reboot.
cat > /etc/systemd/system/intern-task-firewall.service <<'EOF'
[Unit]
Description=Intern Task Docker Firewall
Requires=docker.service
After=docker.service network-online.target
Wants=network-online.target
Before=intern-task-app.service

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/intern-task-firewall.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now intern-task-firewall.service

# --------------------------------------------------
# 4. Retrieve the real Task 1 application
# --------------------------------------------------
mkdir -p /opt/intern-task-app/app

git clone \
  https://github.com/MH469Arya/devops-challenge.git \
  /tmp/devops-challenge

# Pin the source to the Task 1 commit.
git -C /tmp/devops-challenge checkout 635f102

cp /tmp/devops-challenge/intern-task-app/Dockerfile \
  /opt/intern-task-app/Dockerfile

cp /tmp/devops-challenge/intern-task-app/app/app.py \
  /opt/intern-task-app/app/app.py

# --------------------------------------------------
# 5. Build the actual application Docker image
# --------------------------------------------------
docker build \
  -t intern-task-app:local \
  /opt/intern-task-app

# --------------------------------------------------
# 6. Create a systemd-managed Docker container
# --------------------------------------------------
cat > /etc/systemd/system/intern-task-app.service <<'EOF'
[Unit]
Description=Intern Task Python Application
Requires=docker.service intern-task-firewall.service
After=docker.service intern-task-firewall.service network-online.target
Wants=network-online.target

[Service]
Type=simple
Restart=always
RestartSec=5
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker rm -f intern-task-app
ExecStart=/usr/bin/docker run \
  --name intern-task-app \
  --publish 5000:5000 \
  intern-task-app:local
ExecStop=/usr/bin/docker stop intern-task-app

[Install]
WantedBy=multi-user.target
EOF

# --------------------------------------------------
# 7. Enable and start the application service
# --------------------------------------------------
systemctl daemon-reload
systemctl enable --now intern-task-app.service

# --------------------------------------------------
# 8. Verify that the application service is running
# --------------------------------------------------
systemctl is-active --quiet docker
systemctl is-active --quiet intern-task-firewall.service
systemctl is-active --quiet intern-task-app.service

echo "Intern Task application bootstrap completed"