#! /bin/bash

# Ensure that your software packages are up to date on your instance by using the following command to perform a quick software update:
sudo yum update –y

sudo yum upgrade

#  Install unzip
yum install unzip -y

# Create a user soarqube
adduser sonarqube

# Download sonarqube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.4.0.54424.zip

# Unzip sonarqube
unzip *

# Change mode and permissions
chmod -R 755 /home/sonarqube/sonarqube-9.4.0.54424

# Change ownership to sonarqube user
chown -R sonarqube:sonarqube /home/sonarqube/sonarqube-9.4.0.54424

# Change directory into the linux soanrqube distribution
cd sonarqube-9.4.0.54424/bin/linux-x86-64/

# Start sonarqube
./sonar.sh start


