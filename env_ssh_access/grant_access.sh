#!/bin/bash

# service user with paswordless sudo permissions on target machine
SERVICE_USER='dts'
# target user for revoking access
TARGET_USER='user'

usage () {
    echo "Usage:
    grant_access.sh --key_file <public_key_file> --ip <IP>
    Ex.: ./grant_access.sh --key_file my_key.pub --ip 192.168.1.47

    Script to grant access to the specified machine"
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --key_file)
            KEY_FILE="$2"
            shift;;
        --ip)
            IP="$2"
            shift;;
        *)
            usage
            exit 1
            ;;
    esac
    shift
done

cat $KEY_FILE | ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $SERVICE_USER@$IP "sudo tee -a /home/$TARGET_USER/.ssh/authorized_keys"
if [ $? -eq 0 ]; then
    echo "Copied key to $IP"
else
    echo "Can't copy the key to $IP"
    exit 1
fi

echo "Changing owner and permissions"
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -t $SERVICE_USER@$IP "sudo chown $TARGET_USER:$TARGET_USER -R /home/$TARGET_USER/" 
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -t $SERVICE_USER@$IP "sudo chmod 600 /home/$TARGET_USER/.ssh/authorized_keys" 
if [ $? -eq 0 ]; then
    echo "SUCCESS! Connect to $IP as $TARGET_USER"
else
    echo "Can't change permissions. Please check them on $IP"
    exit 1
fi


