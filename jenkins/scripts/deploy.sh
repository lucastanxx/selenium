#!/usr/bin/env sh

# Enable debug mode
set -x

# Check if the container already exists and remove it if it does
docker ps -a | grep my-apache-php-app && docker rm -f my-apache-php-app

# Run Docker container
docker run -d -p 80:80 --name my-apache-php-app -v /c/Users/lucas/Desktop/SSD/Jenkinsv2/jenkins-php-selenium-test/src:/var/www/html php:7.2-apache 2>&1

# Sleep for 1 second to allow things to settle
sleep 1

# Disable debug mode
set +x

echo 'Now...'
echo 'Visit http://localhost to see your PHP application in action.'
