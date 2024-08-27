#!/bin/bash

# Configuration
DEPLOYMENTS_FILE="/home/voganti01/deployments.txt"
DIGEST_DIR="/home/voganti01/digests"
LOG_FILE="/home/voganti01/check_image_updates.log"

# Docker Registry URL and credentials
REGISTRY_URL="https://registry-1.docker.io/v2"
DOCKER_USERNAME="devpentabd"
DOCKER_PASSWORD="c009454d-8639-4395-acbe-7fc6e2c698c8"

# Ensure digest directory exists
mkdir -p "$DIGEST_DIR"

# Function to log in to Docker registry
docker_login() {
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
}

# Log the start time
echo "Running script at $(date)" >> "$LOG_FILE"

# Log in to Docker registry
docker_login

# Read the deployments file
while IFS='|' read -r image_tag deployment_name namespace; do
    if [ -z "$image_tag" ] || [ -z "$deployment_name" ] || [ -z "$namespace" ]; then
        echo "Invalid line in deployments file at $(date): image_tag=$image_tag, deployment_name=$deployment_name, namespace=$namespace" >> "$LOG_FILE"
        continue
    fi

    digest_file="${DIGEST_DIR}/$(echo "$image_tag" | sed 's/:/_/').txt"
    digest_file_dir=$(dirname "$digest_file")
    mkdir -p "$digest_file_dir"

    echo "Pulling image ${image_tag} at $(date)" >> "$LOG_FILE"
    docker pull "$image_tag" >> "$LOG_FILE" 2>&1

    current_digest=$(docker inspect --format='{{index .RepoDigests 0}}' "$image_tag" | awk -F '@' '{print $2}')

    if [ -z "$current_digest" ]; then
        echo "Failed to fetch the current image digest for ${image_tag} at $(date)." >> "$LOG_FILE"
        continue
    fi

    if [ -f "$digest_file" ]; then
        last_digest=$(cat "$digest_file")
    else
        last_digest=""
    fi

    if [ "$current_digest" != "$last_digest" ]; then
        echo "Image ${image_tag} has changed. Triggering rollout restart for ${deployment_name} in namespace ${namespace} at $(date)." >> "$LOG_FILE"
        
        echo "$current_digest" > "$digest_file"
        kubectl rollout restart deployment/"$deployment_name" -n "$namespace" >> "$LOG_FILE" 2>&1
    else
        echo "No changes detected for image ${image_tag} at $(date)." >> "$LOG_FILE"
    fi
done < "$DEPLOYMENTS_FILE"

echo "Script completed at $(date)" >> "$LOG_FILE"
