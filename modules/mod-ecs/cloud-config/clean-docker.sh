#!/bin/bash

function clean_docker_cron() {
    log='/var/log/clean_docker.log'

    cat > /etc/cron.d/clean_docker <<CRONTAB
* * * * * root docker rm -v \$(docker ps -a -q -f status=exited)  && echo \$(date): docker exited cleaned >> $log
* * * * * root docker rmi \$(docker images -f "dangling=true" -q) && echo \$(date): docker null img cleaned >> $log
* * * * * root docker volume rm \$(docker volume ls -qf dangling=true) && echo \$(date): docker volumes cleaned >> $log
CRONTAB
}

function ecr_login() {
    yum update -y
    yum install -y aws-cli jq
    log='/var/log/ecr_login.log'
    EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
    EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed 's/[a-z]$//'`"
    cat > /etc/cron.d/ecr_login <<CRONTAB
* * * * * root \$(aws ecr get-login --no-include-email --region $EC2_REGION)  >> $log
CRONTAB
}

ecr_login
clean_docker_cron
