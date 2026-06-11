#!/bin/bash

#logging file
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
# ======================================================================================================
# EC2 User Data: Automated WordPress with EFS
# ======================================================================================================

# ----- DB Variables
DBName='${DBName}'
DBUser='${DBUser}'
DBPassword='${DBPassword}'
RDSHost='${RDSHost}'


# ----- EFS Variables   (This is not been sent to terraform data source as variables)
FILE_SYSTEM_ID='${FILE_SYSTEM_ID}'
REGION='${REGION}'
MOUNT_POINT='${MOUNT_POINT}'

# ==================================================================
# Install required packages
# ==================================================================
yum update -y
yum install -y git httpd amazon-efs-utils nfs-utils
amazon-linux-extras enable php7.4 -y
yum clean metadata
yum install -y php php-cli php-common php-fpm php-mysqlnd php-json php-pdo \
php-xml php-mbstring php-gd php-opcache php-xmlrpc

# ==================================================================
# Setup EFS Mount (using your working manual method)
# ==================================================================
mkdir -p ${MOUNT_POINT}
chown ec2-user:ec2-user ${MOUNT_POINT}

# Avoid duplicate fstab entries
grep -q "${FILE_SYSTEM_ID}.efs.${REGION}.amazonaws.com" /etc/fstab || \
echo "${FILE_SYSTEM_ID}.efs.${REGION}.amazonaws.com:/ ${MOUNT_POINT} nfs4 defaults,_netdev 0 0" >> /etc/fstab

# Mount EFS
mount -a -t nfs4

# Ensure permissions
chown ec2-user:ec2-user ${MOUNT_POINT}
chmod 755 ${MOUNT_POINT}

# ==================================================================
# Start Apache and PHP
# ==================================================================
systemctl enable httpd
systemctl start httpd
systemctl enable php-fpm
systemctl start php-fpm

# ==================================================================
# Set correct /var/www permissions for WordPress
# ==================================================================
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

# Allow WordPress permalinks
sed -i 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

# ==================================================================
# Deploy WordPress Code from GitHub
# ==================================================================
cd ${MOUNT_POINT}
if [[ -f ${MOUNT_POINT}/wp-config.php ]]
then
  echo "The wordpress file already exists"
else
  echo "Preparing to clone file"
  git clone https://github.com/stackitgit/CliXX_Retail_Repository.git tmp_wp
  cp -r tmp_wp/* ${MOUNT_POINT}
  rm -r tmp_wp
  echo "wordpress file successfully clone"
  
  if [[ -f wp-config.php ]] 
  then
    mv wp-config.php wp-config_old.php
  fi
  # ==================================================================
  # Update WordPress configuration
  # ==================================================================

  cp wp-config-sample.php wp-config.php
  sed -i "s/'database_name_here'/'$DBName'/g" wp-config.php
  sed -i "s/'username_here'/'$DBUser'/g" wp-config.php
  sed -i "s/'password_here'/'$DBPassword'/g" wp-config.php
  sed -i "s/'localhost'/'$RDSHost'/g" wp-config.php

fi

# ==================================================================
# Update WordPress site URL inside RDS
# ==================================================================


mysql -u "$DBUser" -p"$DBPassword" -h "$RDSHost" -D "$DBName" <<EOF

UPDATE wp_options SET option_value = "http://LB1-1754196530.us-east-1.elb.amazonaws.com" WHERE option_value LIKE 'http%';
EOF

# ==================================================================
# Final restart to ensure everything is active
# ==================================================================
systemctl restart httpd
systemctl restart php-fpm
