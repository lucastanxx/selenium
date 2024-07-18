#!/usr/bin/env sh

# Enable script debugging
set -x

# Run Docker container
docker run -d -p 80:80 --name my-apache-php-app -v C:\\Users\\lucas\\Desktop\\SSD\\Jenkinsv2\\jenkins-php-selenium-test\\src:/var/www/html php:7.2-apache

# Pause to allow some time for the container to start
sleep 1

# Perform a curl request to check if the server returns HTTP 200
curl -s -o /dev/null -w "%{http_code}" http://localhost | grep 200 && echo "Application is up and running" || echo "Failed to reach application"

# Disable script debugging
set +x

# Informative message about the application
echo 'Now...'
echo 'Visit http://localhost to see your PHP application in action.'
