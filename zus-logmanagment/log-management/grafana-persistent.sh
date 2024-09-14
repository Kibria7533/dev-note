#!/bin/bash

set -e  # Exit script on any error

MINIO_HOST="http://168.119.108.201:9005"
BUCKET_NAME="grafana-loki"
ACCESS_KEY_ID="9EMN1RlS7WyuVIgkykYb"
ACCESS_SECRET="hSU7kJp5NaanQJqqrD0abdY5U1tYsXOIeXfLU1X9"
MOUNT_FOLDER="/root/log-management/grafana-data"
ENDPOINT="us-east-1"

# Prepare password file
echo "${ACCESS_KEY_ID}:${ACCESS_SECRET}" > ${HOME}/.passwd-s3fs
chmod 600 ${HOME}/.passwd-s3fs

# Ensure folder exists and is empty
sudo mkdir -p ${MOUNT_FOLDER}

# Try to mount, this will unmount when you press Ctrl+C
echo "Attempting to mount bucket..."
sudo s3fs ${BUCKET_NAME} ${MOUNT_FOLDER} \
  -o dbglevel=info -f -o curldbg \
  -o passwd_file=${HOME}/.passwd-s3fs \
  -o host=${MINIO_HOST} \
  -o endpoint=${ENDPOINT} \
  -o use_path_request_style \
  -o allow_other \
  -o ssl_verify_hostname=0 \
  -o no_check_certificate \
  -o connect_timeout=5 \
  -o curldbg=normal \
  -o nonempty

echo "Mount successful. Press Ctrl+C to unmount."

# Backup fstab file
echo "Backing up /etc/fstab..."
mkdir -p ${HOME}/backup
sudo cp /etc/fstab ${HOME}/backup/fstab

# Remove existing entries for grafana-loki
sudo sed -i "/${BUCKET_NAME} ${MOUNT_FOLDER}/d" /etc/fstab

# Append to fstab
echo "Updating /etc/fstab..."
echo "${BUCKET_NAME} ${MOUNT_FOLDER} fuse.s3fs _netdev,passwd_file=${HOME}/.passwd-s3fs,host=${MINIO_HOST},endpoint=${ENDPOINT},use_path_request_style,allow_other,nonempty 0 0" | sudo tee --append /etc/fstab

# Check fstab
echo "Checking /etc/fstab..."
sudo cat /etc/fstab

# Apply updated fstab
echo "Applying updated fstab..."
sudo mount -a

# Check mount status
echo "Checking mount status..."
sudo df -h | grep s3fs

# Clear command history in this session
history -c
