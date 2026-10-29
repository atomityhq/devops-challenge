#!/bin/bash

set -euxo pipefail

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting EC2 application setup..."

# =========================================================
# SYSTEM UPDATE
# =========================================================

dnf update -y


# =========================================================
# APACHE
# =========================================================

dnf install -y httpd

systemctl enable httpd

systemctl start httpd


# =========================================================
# PHP
# =========================================================

dnf install -y \
  php \
  php-cli \
  php-common \
  php-mysqlnd \
  php-fpm \
  php-json \
  php-mbstring \
  php-xml \
  php-gd \
  php-curl \
  php-zip

systemctl enable php-fpm

systemctl start php-fpm


# =========================================================
# MARIA DB
# =========================================================

dnf install -y mariadb105-server

systemctl enable mariadb

systemctl start mariadb


# =========================================================
# APPLICATION DIRECTORY
# =========================================================

mkdir -p /var/www/html

chown -R apache:apache /var/www/html

chmod -R 755 /var/www/html


# =========================================================
# TEST PHP PAGE
# =========================================================

cat > /var/www/html/index.php <<'EOF'
<?php

echo "<h1>Application Server</h1>";
echo "<p>Apache + PHP is running successfully.</p>";

?>
EOF


# =========================================================
# APACHE PHP CONFIGURATION
# =========================================================

systemctl restart httpd


# =========================================================
# CLOUDWATCH AGENT
# =========================================================

dnf install -y amazon-cloudwatch-agent


# =========================================================
# SSM AGENT
# =========================================================

dnf install -y amazon-ssm-agent

systemctl enable amazon-ssm-agent

systemctl start amazon-ssm-agent


# =========================================================
# DATA VOLUME
# =========================================================

DEVICE="/dev/sdf"

MOUNT_POINT="/data"

mkdir -p "${MOUNT_POINT}"

if [ -b "${DEVICE}" ]; then

    if ! blkid "${DEVICE}"; then
        mkfs -t xfs "${DEVICE}"
    fi

    UUID=$(blkid -s UUID -o value "${DEVICE}")

    if ! grep -q "${UUID}" /etc/fstab; then
        echo "UUID=${UUID} ${MOUNT_POINT} xfs defaults,nofail 0 2" >> /etc/fstab
    fi

    mount -a

fi


# =========================================================
# CLOUDWATCH AGENT START
# =========================================================

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c ssm:/myapp/dev/cloudwatch-agent \
  -s || true


# =========================================================
# PERMISSIONS
# =========================================================

chown -R apache:apache /var/www/html

chmod -R 755 /var/www/html


echo "EC2 application setup completed."