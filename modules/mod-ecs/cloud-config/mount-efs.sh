#!/bin/bash

function mount_efs() {
    yum update -y
    yum install -y nfs-utils
    mkdir ${EFS_MOUNT_POINT}
    echo -e "${EFS_DNS}:/ ${EFS_MOUNT_POINT} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" >> /etc/fstab
    mount -a
    chmod a+rwx "${EFS_MOUNT_POINT}"
}

mount_efs
