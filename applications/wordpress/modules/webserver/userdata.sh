#!/bin/bash
yum update -y
yum install -y httpd.x86_64
systemctl start httpd.service
systemctl enable httpd.service
mkdir -p /var/www/html/
echo “Hello World from $(hostname -f)” > /var/www/html/index.html