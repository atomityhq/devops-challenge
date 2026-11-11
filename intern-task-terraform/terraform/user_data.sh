#!/bin/bash
set -euxo pipefail

# This command creates a non root user with passwordless sudo
if ! id internapp >/dev/null 2>&1; then
    useradd --create-home --shell /bin/bash internapp
fi

usermod -aG wheel internapp

echo 'internapp ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/internapp
chmod 0440 /etc/sudoers.d/internapp
visudo -cf /etc/sudoers.d/internapp

# Install and start Docker and the host firewall
dnf install -y docker firewalld iptables

systemctl enable --now docker
systemctl enable --now firewalld

# it allow SSH only from the configured CIDR and the application port
firewall-cmd --set-default-zone=public
firewall-cmd --permanent --zone=public --remove-service=ssh || true
firewall-cmd --permanent --zone=public --add-rich-rule="rule family=ipv4 source address=${ssh_cidr} port port=22 protocol=tcp accept"
firewall-cmd --permanent --zone=public --add-port=${app_port}/tcp
firewall-cmd --reload

# Restrict traffic forwarded to Docker containers
cat > /usr/local/sbin/docker-firewall.sh <<'EOF'
#!/bin/bash
set -euo pipefail

PUBLIC_IF=$(ip route get 1.1.1.1 | awk '{for (i=1; i<=NF; i++) if ($i=="dev") {print $(i+1); exit}}')

iptables -C DOCKER-USER -i "$PUBLIC_IF" -p tcp --dport ${app_port} -j RETURN 2>/dev/null || \
iptables -I DOCKER-USER 1 -i "$PUBLIC_IF" -p tcp --dport ${app_port} -j RETURN

iptables -C DOCKER-USER -i "$PUBLIC_IF" -j DROP 2>/dev/null || \
iptables -I DOCKER-USER 2 -i "$PUBLIC_IF" -j DROP
EOF

chmod +x /usr/local/sbin/docker-firewall.sh

cat > /etc/systemd/system/docker-firewall.service <<'EOF'
[Unit]
Description=Restrict inbound Docker container traffic
Requires=docker.service
After=docker.service firewalld.service

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/docker-firewall.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now docker-firewall.service

# Prepare the application directory
mkdir -p /opt/intern-task-app/app

# Restore it from the actual Task 1 application and Dockerfile
printf '%s' '${app_py_b64}' | base64 -d > /opt/intern-task-app/app/app.py
printf '%s' '${dockerfile_b64}' | base64 -d > /opt/intern-task-app/Dockerfile

# Build the application image using the Task 1 Dockerfile
docker build -t intern-task-app:local /opt/intern-task-app

# Create a systemd service to manage the application container
cat > /etc/systemd/system/intern-task-app.service <<EOF
[Unit]
Description=Intern Task Application Container
Requires=docker.service
After=docker.service

[Service]
Restart=always
RestartSec=5
ExecStartPre=-/usr/bin/docker rm -f intern-task-app
ExecStart=/usr/bin/docker run --rm --name intern-task-app -p ${app_port}:${app_port} intern-task-app:local
ExecStop=/usr/bin/docker stop intern-task-app

[Install]
WantedBy=multi-user.target
EOF

# This command enables the application service at boot
systemctl daemon-reload
systemctl enable --now intern-task-app.service
