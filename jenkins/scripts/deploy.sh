#!/usr/bin/env sh

# Enable debug mode for verbose output
set -x

# Define variables
PORT=80
HOSTNAME=localhost
CONTAINER_NAME=my-apache-php-app
SOURCE_DIR=/c/Users/lucas/Desktop/SSD/Jenkinsv2/jenkins-php-selenium-test/src

# Check if the container already exists and remove it
if docker ps -a | grep -q $CONTAINER_NAME; then
    docker rm -f $CONTAINER_NAME
fi

# Run Docker container
docker run -d -p ${PORT}:${PORT} --name $CONTAINER_NAME -v $SOURCE_DIR:/var/www/html php:7.2-apache 2>&1

# Sleep to allow the container to start properly
sleep 1

# Check if the container is running, if not, exit with an error
if ! docker ps | grep -q $CONTAINER_NAME; then
    echo "Failed to start container $CONTAINER_NAME"
    exit 1
fi

# Display container logs for debugging
echo "Docker container logs:"
docker logs $CONTAINER_NAME

# Check if Apache is running inside the container
echo "Checking if Apache is running:"
docker exec $CONTAINER_NAME ps aux | grep apache

# Check the contents of the web root directory
echo "Contents of the web root directory:"
docker exec $CONTAINER_NAME ls -la /var/www/html

# Perform a curl request to check if the PHP application is accessible
HTTP_STATUS=$(curl -s -o /dev/null -w '%{http_code}' http://$HOSTNAME)
echo "HTTP Status: $HTTP_STATUS"

if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "Visit http://$HOSTNAME to see your PHP application in action."
else
    echo "Failed to reach application, HTTP status: $HTTP_STATUS"
    echo "Checking Apache error logs:"
    docker exec $CONTAINER_NAME cat /var/log/apache2/error.log
    exit 2
fi

# Disable debug mode
set +x
