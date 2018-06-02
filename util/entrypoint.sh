#!/bin/bash

set -e

# Single argument to command line is to run named
if [ -n "$1" -a "$1" == "named" ]; then
    # Run named

    confdir="/etc/bind"
    if [ ! -d "$confdir" ]; then
        echo "Please ensure '$confdir' folder is available."
        exit 1
    fi

    zonedir="/var/lib/bind"
    if [ ! -r "$zonedir" ]; then
        echo "Please ensure '$zonedir' exists and is readable."
        exit 1
    fi

    uid=$(stat -c%u "$confdir")
    gid=$(stat -c%g "$confdir")
    if [ $gid -ne 0 ]; then
        groupmod -g $gid bind || groupadd -g $gid bind
    fi
    if [ $uid -ne 0 ]; then
        usermod -u $uid bind || useradd -u $uid -g $gid bind
    fi

    # Log to this file for debugging.
    logfile="/var/log/named.log"
    if [ ! -e "$logfile" ]; then
        touch $logfile
        chmod 666 $logfile
    fi

    container_id=$(grep docker /proc/self/cgroup | sort -n | head -n 1 | cut -d: -f3 | cut -d/ -f5)
    if perl -e '($id,$name)=@ARGV;$short=substr $id,0,length $name;exit 1 if $name ne $short;exit 0' $container_id $HOSTNAME; then
        echo "You must add the 'docker run' option '--net=host' if you want to provide DNS service to the host network."
    fi

    exec /usr/sbin/named -f -u bind
else
    exec "$1"
fi
