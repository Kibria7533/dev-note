#!/bin/bash

# Script to clone repositories based on a keyword and destination directory.

# Verify if 'gh' CLI is installed
if ! command -v gh &>/dev/null; then
  echo "Error: GitHub CLI (gh) is not installed. Please install it first."
  exit 1
fi

# Verify if 'jq' is installed
if ! command -v jq &>/dev/null; then
  echo "Error: jq is not installed. Please install it first."
  exit 1
fi

# Prompt for GitHub authentication (ensure user is logged in)
echo "Checking GitHub authentication..."
if ! gh auth status &>/dev/null; then
  echo "You need to authenticate GitHub CLI. Logging in..."
  gh auth login
fi

# Prompt for keyword to match repositories
read -p "Enter a keyword to search in repository names: " keyword
if [[ -z "$keyword" ]]; then
  echo "Error: Keyword cannot be empty. Exiting."
  exit 1
fi

# Prompt for the destination directory
read -p "Enter the directory path where you want to clone repositories: " dest_dir
if [[ -z "$dest_dir" ]]; then
  echo "Error: Destination directory cannot be empty. Exiting."
  exit 1
fi

# Create the directory if it doesn't exist
if [[ ! -d "$dest_dir" ]]; then
  echo "Directory does not exist. Creating $dest_dir..."
  mkdir -p "$dest_dir"
fi

# Fetch repositories matching the keyword from the specified organization
echo "Fetching repositories from organization 'pentaglobalsltd' matching keyword '$keyword'..."
repos=$(gh repo list pentaglobalsltd --limit 100 --json name,sshUrl | \
  jq -r --arg keyword "$keyword" '.[] | select(.name | contains($keyword)) | .sshUrl')

# Check if any repositories matched the keyword
if [[ -z "$repos" ]]; then
  echo "No matching repositories found for keyword '$keyword'. Exiting."
  exit 1
fi

# Clone each repository into the destination directory
echo "Cloning repositories into $dest_dir..."
cd "$dest_dir" || { echo "Error: Cannot change to directory $dest_dir"; exit 1; }

for repo in $repos; do
  repo_name=$(basename "$repo" .git)
  echo "Cloning repository: $repo_name..."
  if git clone "$repo"; then
    echo "Successfully cloned $repo_name."
  else
    echo "Failed to clone $repo_name."
  fi
done

echo "All matching repositories have been cloned successfully."