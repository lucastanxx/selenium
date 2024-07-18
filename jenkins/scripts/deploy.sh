#!/usr/bin/env sh

# Enable debug mode
set -x

# Define variables
PORT=80
HOSTNAME=localhost
CONTAINER_NAME=my-apache-php-app
SOURCE_DIR=/var/jenkins_home/workspace/selenium/src
NETWORK_NAME=jenkins

# Check if the network exists and create it if not
docker network inspect $NETWORK_NAME >/dev/null 2>&1 || docker network create $NETWORK_NAME

# Check if the container already exists and remove it if it does
docker ps -a | grep $CONTAINER_NAME && docker rm -f $CONTAINER_NAME

# Display contents of the source directory
echo "Contents of the source directory on the host:"
ls -la $SOURCE_DIR

# Run Docker container
docker run -d -p ${PORT}:${PORT} --name $CONTAINER_NAME --network $NETWORK_NAME -v $SOURCE_DIR:/var/www/html php:7.2-apache

# Sleep for 5 seconds to allow the container to start
sleep 5

# Check if the container is running
if ! docker ps | grep $CONTAINER_NAME; then
    echo "Failed to start container"
    exit 1
fi

# Display Docker container logs
echo "Docker container logs:"
docker logs $CONTAINER_NAME

# Check if Apache is running
echo "Checking if Apache is running:"
docker exec $CONTAINER_NAME ps aux | grep apache

# Display contents of the web root directory
echo "Contents of the web root directory:"
docker exec $CONTAINER_NAME ls -la /var/www/html

# Display permissions of the web root directory
echo "Permissions of the web root directory:"
docker exec $CONTAINER_NAME ls -la /var/www

# Get the container IP address
CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME)
echo "Container IP address: $CONTAINER_IP"

# Perform a curl request to check if the PHP application is live
HTTP_STATUS=$(curl -s -o /dev/null -w '%{http_code}' http://$CONTAINER_IP)
echo "HTTP Status: $HTTP_STATUS"
if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "Visit http://$CONTAINER_IP to see your PHP application in action."
else
    echo "Failed to reach application, HTTP status: $HTTP_STATUS"
    exit 2
fi

# Display Apache error logs
echo "Checking Apache error logs:"
docker exec $CONTAINER_NAME cat /var/log/apache2/error.log

# Disable debug mode
set +x
