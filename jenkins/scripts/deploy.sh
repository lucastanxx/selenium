#!/usr/bin/env sh

# Enable debug mode for verbose output
set -x

# Define variables
PORT=80
HOSTNAME=localhost
CONTAINER_NAME=my-apache-php-app
SOURCE_DIR="/var/jenkins_home/workspace/selenium/src"

# Check if the container already exists and remove it if it does
if docker ps -a | grep -q $CONTAINER_NAME; then
    docker rm -f $CONTAINER_NAME
fi

# Verify the contents of the source directory on the host
echo "Contents of the source directory on the host:"
ls -la "$SOURCE_DIR"

# Run Docker container
docker run -d -p ${PORT}:${PORT} --name $CONTAINER_NAME -v "$SOURCE_DIR":/var/www/html php:7.2-apache 2>&1

# Sleep to allow the container to start properly
sleep 5

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

# Check the contents of the web root directory inside the container
echo "Contents of the web root directory:"
docker exec $CONTAINER_NAME ls -la /var/www/html

# Check the permissions of the mounted directory
echo "Permissions of the web root directory:"
docker exec $CONTAINER_NAME ls -la /var/www

# Get the container's IP address
CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME)
echo "Container IP address: $CONTAINER_IP"

# Perform a curl request to check if the PHP application is accessible
echo "Performing curl request to container IP address:"
HTTP_STATUS=$(curl -s -o /dev/null -w '%{http_code}' http://$CONTAINER_IP)
echo "HTTP Status from container IP: $HTTP_STATUS"

echo "Performing curl request to localhost:"
HTTP_STATUS_LOCAL=$(curl -s -o /dev/null -w '%{http_code}' http://$HOSTNAME)
echo "HTTP Status from localhost: $HTTP_STATUS_LOCAL"

if [ "$HTTP_STATUS_LOCAL" -eq 200 ]; then
    echo "Visit http://$HOSTNAME to see your PHP application in action."
else
    echo "Failed to reach application via localhost, HTTP status: $HTTP_STATUS_LOCAL"
    echo "Failed to reach application via container IP, HTTP status: $HTTP_STATUS"
    echo "Checking Apache error logs:"
    docker exec $CONTAINER_NAME cat /var/log/apache2/error.log
    exit 2
fi

# Disable debug mode
set +x
