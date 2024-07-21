#!/usr/bin/env sh

set -x
docker run -d -p 80:80 --name my-apache-php-app -v "C:\Users\lucas\Desktop\SSD\Jenkinsv2\jenkins-php-selenium-test\selenium\src:/var/www/html" php:7.2-apache
sleep 1
set +x

echo 'Now...'
echo 'Visit http://localhost to see your PHP application in action.'
