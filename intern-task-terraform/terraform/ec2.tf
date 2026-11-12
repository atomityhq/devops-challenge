resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = tolist([aws_security_group.example.id]) 
  associate_public_ip_address = true
  
user_data = <<-EOF
#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y docker.io git ufw sudo ca-certificates

#--------Create non-root user----------------
useradd -m -s /bin/bash appuser
usermod -aG sudo appuser
echo "appuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/appuser
chmod 0440 /etc/sudoers.d/appuser
visudo -cf /etc/sudoers.d/appuser

#--------Start Docker---------
systemctl enable --now docker

git clone --depth 1 --branch main \
  https://github.com/y0usefAhmed/devops-challenge.git \
  /opt/devops-challenge

docker build -t intern-task-app:local \
  /opt/devops-challenge/intern-task-app

#-------Configure host firewall-------
ufw default deny incoming
ufw default allow outgoing
ufw allow 5000/tcp
ufw --force enable

#------------Create systemd service-----------------------
cat > /etc/systemd/system/intern-task-app.service <<'SERVICE'
[Unit]
Description=Intern Task App Container
Requires=docker.service
After=docker.service

[Service]
Restart=always
RestartSec=5
ExecStartPre=-/usr/bin/docker rm -f intern-task-app
ExecStart=/usr/bin/docker run --name intern-task-app --network host -e PORT=5000 intern-task-app:local
ExecStop=/usr/bin/docker stop --time 10 intern-task-app
ExecStopPost=-/usr/bin/docker rm -f intern-task-app

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable --now intern-task-app

EOF

  user_data_replace_on_change = false

  tags = {
    Name = "dev-task"
  }
}