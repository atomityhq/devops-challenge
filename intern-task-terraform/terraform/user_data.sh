#!/bin/bash
set -euxo pipefail

# Update the operating system.
yum update -y

# Create a non-root user with passwordless sudo.
useradd -m -s /bin/bash devops
echo "devops ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/devops
chmod 440 /etc/sudoers.d/devops

# Install Docker and firewall persistence tools.
amazon-linux-extras install docker -y
yum install -y iptables-services

# Enable and start Docker.
systemctl enable docker
systemctl start docker

# Create the application directory.
mkdir -p /opt/intern-task-app/app

# Decode the application files supplied by Terraform.
echo "${dockerfile_b64}" | base64 -d > /opt/intern-task-app/Dockerfile
echo "${app_source_b64}" | base64 -d > /opt/intern-task-app/app/app.py

# Build the actual application image.
docker build -t intern-task-app:local /opt/intern-task-app

# Create a systemd service for the application container.
cat > /etc/systemd/system/intern-task-app.service <<'EOF'
[Unit]
Description=Intern Task Application Container
Requires=docker.service docker-firewall.service
After=docker.service docker-firewall.service

[Service]
Restart=always
ExecStartPre=-/usr/bin/docker rm -f intern-task-app
ExecStart=/usr/bin/docker run --name intern-task-app -p 8080:8080 intern-task-app:local
ExecStop=/usr/bin/docker stop intern-task-app

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the application service.


# Configure the host firewall.
iptables -F INPUT
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT

# Allow local traffic.
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections.
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow DHCP responses from the AWS network.
iptables -A INPUT -p udp --sport 67 --dport 68 -j ACCEPT

# Allow SSH only from the configured CIDR.
iptables -A INPUT -p tcp -s "${ssh_allowed_cidr}" --dport 22 -j ACCEPT

# Allow application traffic on port 8080.
iptables -A INPUT -p tcp --dport 8080 -j ACCEPT

# Save host firewall rules.
service iptables save
systemctl enable iptables

# Configure Docker's forwarding firewall.
cat > /usr/local/sbin/configure-docker-firewall.sh <<'FIREWALL'
#!/bin/bash
set -e

iptables -N DOCKER-USER 2>/dev/null || true
iptables -F DOCKER-USER

# Allow established connections.
iptables -A DOCKER-USER -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow incoming application traffic to the container.
iptables -A DOCKER-USER -p tcp --dport 8080 -j ACCEPT

# Drop all other forwarded traffic.
iptables -A DOCKER-USER -j DROP
FIREWALL

chmod 700 /usr/local/sbin/configure-docker-firewall.sh

# Apply Docker firewall rules.
/usr/local/sbin/configure-docker-firewall.sh

# Restore Docker firewall rules after Docker starts on reboot.
cat > /etc/systemd/system/docker-firewall.service <<'SERVICE'
[Unit]
Description=Configure Docker container firewall
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/configure-docker-firewall.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable docker-firewall.service
# Load the systemd service definitions.

# Enable and start the application after its firewall dependency.
systemctl enable intern-task-app.service
systemctl start intern-task-app.service
