#!/bin/bash

# service user with paswordless sudo permissions on target machine
SERVICE_USER='dts'
# target user for revoking access
TARGET_USER='user'

usage () {
    echo "Usage:
    revoke_access.sh --ip <ip>
    Ex.: ./revoke_access.sh  --ip 192.168.15.15

    Script to revoke SSH access from the specified machine"
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
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

echo "Removing authorized_keys from $IP"
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $SERVICE_USER@$IP -t 'sudo rm /home/$TARGET_USER/.ssh/authorized_keys'

ssh $SERVICE_USER@$IP "sudo rm /home/$TARGET_USER/.bash_history"
if [ $? -eq 0 ]; then
    echo "Removed user bash_history $IP"
else
    echo "No history to clean up"
fi