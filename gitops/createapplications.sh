#!/bin/bash

# Load variables from variables.txt
source variables.txt

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

# Prompt for common details to apply to all applications
read -p "Enter the branch name for applications (e.g., main): " branch_name
read -p "Enter the folder path within each repo for the Helm chart (e.g., charts): " folder_path
read -p "Enter the namespace for all applications: " namespace

# Verify if urls.txt exists
if [[ ! -f "urls.txt" ]]; then
  echo "Error: urls.txt file not found."
  exit 1
fi

# Process each repository in urls.txt
while IFS= read -r repo_url; do
  # Skip empty lines or invalid URLs
  if [[ -z "$repo_url" ]]; then
    echo "Warning: Skipping empty line in urls.txt"
    continue
  fi

  # Extract the repo_name from the URL
  repo_name=$(basename "$repo_url" .git)

  # Debugging: Print the extracted repo_name
  echo "Debug: Extracted repo_name is '$repo_name' from URL '$repo_url'"

  # Check if repo_name is empty or invalid
  if [[ -z "$repo_name" ]]; then
    echo "Error: Failed to extract repo_name from URL $repo_url. Skipping this repository."
    continue
  fi

  app_name="${repo_name}-${branch_name}"
  echo "Processing repository $repo_name from $repo_url..."
  echo "Application name will be $app_name"

  # Check if the application already exists in ArgoCD
  if argocd app get "$app_name" &>/dev/null; then
    echo "Application $app_name already exists in ArgoCD. Skipping."
  else
    # Create the application
    echo "Creating application $app_name in ArgoCD..."

    argocd app create "$app_name" \
      --repo "$repo_url" \
      --path "$folder_path" \
      --revision "$branch_name" \
      --dest-server "https://kubernetes.default.svc" \
      --dest-namespace "$namespace" \
      --name "$app_name" \
      --project "default" \
      --sync-policy "automated" \
      --values "values.yaml" \
      --helm-set "syncPolicy.automated=true"

    if [[ $? -eq 0 ]]; then
      echo "Application $app_name created successfully."
    else
      echo "Error: Failed to create application $app_name."
    fi

    # Wait a few seconds after creating to ensure stability
    echo "Waiting for ArgoCD to process the creation..."
    sleep 5
  fi
done < urls.txt

echo "All applications processed."
