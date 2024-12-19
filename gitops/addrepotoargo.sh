#!/bin/bash

# Load variables from variables.txt
source variables.txt

# SSH Key Selection
echo "Please select the SSH key to use for adding repositories to ArgoCD:"
ssh_keys=()
index=1
for key in ~/.ssh/id_*; do
  if [[ -f "$key" && "$key" != *.pub ]]; then
    echo "$index) $key"
    ssh_keys+=("$key")
    ((index++))
  fi
done

if [[ ${#ssh_keys[@]} -eq 0 ]]; then
  echo "No SSH keys found in ~/.ssh. Exiting."
  exit 1
fi

read -p "Enter the number of the SSH key you want to use: " key_choice
if [[ "$key_choice" -ge 1 && "$key_choice" -le ${#ssh_keys[@]} ]]; then
  ssh_key_path="${ssh_keys[$((key_choice - 1))]}"
else
  echo "Invalid choice. Exiting."
  exit 1
fi

# ArgoCD Login Function with Retry
login_to_argocd() {
  local retries=5
  local wait_time=10
  local attempt=1

  while (( attempt <= retries )); do
    echo "Attempt $attempt: Logging into ArgoCD at $ARGOCD_SERVER..."
    argocd login "$ARGOCD_SERVER" --username "$ARGOCD_USERNAME" --password "$ARGOCD_PASSWORD" --insecure

    if [[ $? -eq 0 ]]; then
      echo "Successfully logged into ArgoCD."
      return 0
    else
      echo "Login attempt $attempt failed. Retrying in $wait_time seconds..."
      sleep $wait_time
      ((attempt++))
    fi
  done

  echo "Error: Failed to login to ArgoCD after $retries attempts."
  exit 1
}

# Attempt ArgoCD Login
login_to_argocd

# Process each repository in urls.txt
while IFS= read -r repo_url; do
  repo_name=$(basename "$repo_url" .git)
  echo "Processing repository $repo_name from $repo_url..."

  # Check if the repository already exists in ArgoCD
  if argocd repo get "$repo_url" &>/dev/null; then
    echo "Repository $repo_name already exists in ArgoCD. Skipping."
  else
    # Add the repository if it doesn't exist
    echo "Adding repository $repo_name to ArgoCD under the 'default' project using SSH key $ssh_key_path..."
    argocd repo add "$repo_url" \
      --ssh-private-key-path "$ssh_key_path" \
      --name "$repo_name" \
      --project "default"
    
    if [[ $? -eq 0 ]]; then
      echo "Repository $repo_name added successfully."
    else
      echo "Error: Failed to add repository $repo_name."
    fi

    # Wait a few seconds after adding to ensure stability
    echo "Waiting for ArgoCD to process the addition..."
    sleep 5
  fi
done < urls.txt

echo "All repositories processed."
