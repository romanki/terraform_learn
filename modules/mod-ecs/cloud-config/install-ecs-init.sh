#!/bin/bash

function install_ecs_init() {
    yum install ecs-init -y
    [[ $? == 0 ]] && start ecs
}

install_ecs_init
