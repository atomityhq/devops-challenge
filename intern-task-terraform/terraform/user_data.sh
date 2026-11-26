
#!/bin/bash

set -euxo pipefail

# ----------------------------------------
# 1. Updated system and installed packages
# ----------------------------------------

dnf update -y

dnf install -y docker git firewalld

# ----------------------------------------
# 2. A non-root user
# ----------------------------------------

useradd --create-home --shell /bin/bash appadmin || true

usermod -aG wheel appadmin

# Configured passwordless sudo
cat > /etc/sudoers.d/appadmin <<'EOF'
appadmin ALL=(ALL) NOPASSWD: ALL
EOF

chmod 0440 /etc/sudoers.d/appadmin

# Locked password-based login for this user
passwd -l appadmin || true

# ----------------------------------------
# 3. Install and enable Docker
# ----------------------------------------

systemctl enable --now docker

# Allow the new user to use Docker
usermod -aG docker appadmin

# ----------------------------------------
# 4. Clone the actual application repository
# ----------------------------------------

APP_REPO_URL="https://github.com/OMaryann/devops-challenge.git"

APP_BRANCH="feature/intern-task-app"

APP_DIR="/opt/intern-task-app"

git clone \
  --branch "$APP_BRANCH" \
  --single-branch \
  "$APP_REPO_URL" \
  "$APP_DIR"

# ----------------------------------------
# 5. The actual application image
# ----------------------------------------

cd "$APP_DIR/intern-task-app"

docker build -t intern-task-app:local .

# ----------------------------------------
# 6. A systemd service
# ----------------------------------------

cat > /etc/systemd/system/intern-task-app.service <<'EOF'
[Unit]
Description=Intern Task Python Application Container
Requires=docker.service
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=simple

ExecStartPre=-/usr/bin/docker rm -f intern-task-app

ExecStart=/usr/bin/docker run \
  --name intern-task-app \
  -p 5000:5000 \
  intern-task-app:local

ExecStop=/usr/bin/docker stop intern-task-app

Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# ----------------------------------------
# 7. Enabling and starting the application service
# ----------------------------------------

systemctl daemon-reload

systemctl enable --now intern-task-app.service

# ----------------------------------------
# 8. Configuring the host firewall
# ----------------------------------------

systemctl enable --now firewalld

# Using a restrictive default policy
firewall-cmd --permanent --zone=public --set-target=DROP

# Allowing the application's actual listening port
firewall-cmd --permanent --zone=public --add-port=5000/tcp

# Applying firewall rules
firewall-cmd --reload

# ----------------------------------------
# 9. Record successful initialization
# ----------------------------------------

echo "Intern task application setup completed." \
  > /var/log/intern-task-app-setup.log
