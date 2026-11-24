resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  user_data_replace_on_change = false

  user_data = <<-USERDATA
    #!/bin/bash
    set -eux

    # Create a non-root user with passwordless sudo
    useradd -m -G wheel internuser || true
    echo "internuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/internuser
    chmod 440 /etc/sudoers.d/internuser

    # Install Docker, Git and firewalld
    dnf install -y docker git firewalld

    systemctl enable --now docker
    systemctl enable --now firewalld

    # Download the actual Task 1 application
    git clone --depth 1 --branch task1-docker-k8s \
      https://github.com/Aditya-Kumar355/devops-challenge.git \
      /opt/devops-challenge

    # Build the application image from Task 1 Dockerfile
    docker build -t intern-task-app:local \
      /opt/devops-challenge/intern-task-app

    # Create a systemd service to manage the container
    cat > /etc/systemd/system/intern-task-app.service <<'UNIT'
    [Unit]
    Description=Intern Task Application Container
    Requires=docker.service
    After=docker.service network-online.target
    Wants=network-online.target

    [Service]
    Type=simple
    ExecStartPre=-/usr/bin/docker rm -f intern-task-app
    ExecStart=/usr/bin/docker run --name intern-task-app -p 8080:8080 --restart=no intern-task-app:local
    ExecStop=/usr/bin/docker stop intern-task-app
    ExecStopPost=-/usr/bin/docker rm -f intern-task-app
    Restart=always
    RestartSec=5

    [Install]
    WantedBy=multi-user.target
    UNIT

    systemctl daemon-reload
    systemctl enable --now intern-task-app.service

    # Configure host firewall: app port open, SSH restricted to approved CIDR
    firewall-cmd --permanent --zone=public --remove-service=ssh || true
    firewall-cmd --permanent --zone=public --remove-service=dhcpv6-client || true
    firewall-cmd --permanent --zone=public --add-port=8080/tcp

    firewall-cmd --permanent --zone=public \
      --add-rich-rule='rule family="ipv4" source address="${var.ssh_cidr}" port port="22" protocol="tcp" accept'

    firewall-cmd --reload
  USERDATA

  tags = {
    Name = "${var.project_name}-ec2"
  }
}
