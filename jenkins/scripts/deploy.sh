#!/usr/bin/env sh

# Enable debug mode
set -x

# Define variables
PORT=80
HOSTNAME=localhost
CONTAINER_NAME=my-apache-php-app
SOURCE_DIR="/c/Users/lucas/Desktop/SSD/Jenkinsv2/jenkins-php-selenium-test/src"

# Check if the container already exists and remove it if it does
docker ps -a | grep $CONTAINER_NAME && docker rm -f $CONTAINER_NAME

# Run Docker container
docker run -d -p ${PORT}:${PORT} --name $CONTAINER_NAME -v $SOURCE_DIR:/var/www/html php:7.2-apache 2>&1

# Sleep for a few seconds to allow the container to start
sleep 5

# Display Docker container logs
docker logs $CONTAINER_NAME

# Display Apache process status
docker exec $CONTAINER_NAME ps aux | grep apache

# Display Apache error and access logs
docker exec $CONTAINER_NAME cat /var/log/apache2/error.log
docker exec $CONTAINER_NAME cat /var/log/apache2/access.log

# Check if the container is running
if ! docker ps | grep $CONTAINER_NAME; then
    echo "Failed to start container"
    exit 1
fi

# Perform a curl request to check if the PHP application is live
HTTP_STATUS=$(curl -s -o /dev/null -w '%{http_code}' http://$HOSTNAME)
if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "Visit http://$HOSTNAME to see your PHP application in action."
else
    echo "Failed to reach application, HTTP status: $HTTP_STATUS"
    exit 2
fi

# Disable debug mode
set +x
