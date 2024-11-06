#!/bin/bash
# 1. hostname
# How to use:
# ./ufw unix.stackexchange.com 5432

declare HOSTNAME=$1
declare PORT=$2
declare OLD_HOSTS_FILE=$HOME/$HOSTNAME.$PORT.backup
declare OLD_HOSTS_CONTENT=$(cat $OLD_HOSTS_FILE)
declare NEW_HOSTS_CONTENT=$(getent hosts $HOSTNAME | awk '{ print $1 }' | sort)

# Check if hosts is equals
declare OLD_HOSTS_CONTENT64=$(echo $OLD_HOSTS_CONTENT | base64)
declare NEW_HOSTS_CONTENT64=$(echo $NEW_HOSTS_CONTENT | base64)
if [ "$OLD_HOSTS_CONTENT64" == "$NEW_HOSTS_CONTENT64" ] ; then
  echo IP address has not changed
  exit
fi

# Remove old hosts
declare -a HOSTS=($OLD_HOSTS_CONTENT)
for Old_IP in "${HOSTS[@]}"
do
  echo Remove old host $Old_IP
  /usr/sbin/ufw delete allow from $Old_IP to any port $PORT proto tcp
done

# Add new hosts
declare -a HOSTS=($NEW_HOSTS_CONTENT)
for Current_IP in "${HOSTS[@]}"
do
  echo Add host $Current_IP
  /usr/sbin/ufw allow from $Current_IP to any port $PORT proto tcp
done
echo $NEW_HOSTS_CONTENT > $OLD_HOSTS_FILE