#!/usr/bin/env sh

# Enable command echo
set -x

# Set variables
PORT=80
HOSTNAME="localhost"
CONTAINER_NAME="my-apache-php-app"

# Run Docker container
docker run -d -p ${PORT}:${PORT} --name ${CONTAINER_NAME} -v c:/path/to/jenkins-php-selenium-test/src:/var/www/html php:7.2-apache

# Disable command echo
set +x

# Give some time for the container to start
sleep 5

# Define the URL
URL="http://${HOSTNAME}:${PORT}"

# Print URL and port
echo "Now..."
echo "Visit ${URL} to see your PHP application in action."

# Ping the application to check for a 200 OK response
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "${URL}")

if [ "$RESPONSE" -eq 200 ]; then
    echo "Success: Server responded with HTTP 200."
else
    echo "Error: Server response was HTTP $RESPONSE."
fi

