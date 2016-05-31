#!/bin/bash
# author liyankun
#set -x

prefix=sunfir::storage::ceph::cluster::
partitions_list=''
disks_list=''
service_type=''
device_type=''
system_dir='/var/ceph'

function usage(){
    cat <<- EOF
    Usage:
        ceph_puppet.sh service_type [device_type]
EOF
    exit 1
}

#disks_or_partitions_list=`lsblk -rfnto name`

function get_raw_disk(){
    for device in $(lsblk -rfnto name);
    do 
        if [ ${#device} -gt 3 ]; then
            partitions_list=$partitions_list:${device}
        else
            disks_list=$disks_list:${device}
        fi
    done

    for device in ${partitions_list//:/ };
    do
        disks_list=${disks_list//:${device:0:3}/ }
    done
}


function enable_service(){
    echo ${prefix}enable_$service_type": true"
}

function format_disk_to_puppet(){
    echo ${prefix}osd_device_dict":"
    if [ -z $disks_list ]; then
        mkdir -p $system_dir
        echo "  \"/var/ceph\"":"\"\""
    else
        for item in ${disks_list//:/ };
        do
            echo "  \"/dev/$item\"":"\"\""
        done
    fi 
}

function main(){
    if [ -z $device_type ]; then
        enable_service
    else
        enable_service
        get_raw_disk
        echo ${prefix}disk_type": $device_type"
        format_disk_to_puppet
    fi
    exit 0
}


if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo $#
    usage
elif [[ $# = 1 ]]; then
    service_type=$1
else
    service_type=$1
    device_type=$2
fi

main 
