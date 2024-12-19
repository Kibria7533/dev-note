#!/bin/bash

# Load variables from variables.txt
source variables.txt

# Check if GIT_OWNER is set
if [[ -z "$GIT_OWNER" ]]; then
  echo "Error: GIT_OWNER not found in variables.txt."
  exit 1
fi

# Prompt user for the keyword to search in repository names
read -p "Enter a keyword to search in repository names: " keyword

# Fetch the list of repositories for the specified owner and filter by keyword
gh repo list "$GIT_OWNER" --limit 100 --json name,sshUrl | \
  jq -r --arg keyword "$keyword" '.[] | select(.name | contains($keyword)) | .sshUrl' > urls.txt

# Check if urls.txt has content
if [[ -s urls.txt ]]; then
  echo "Matching SSH URLs saved to urls.txt:"
  cat urls.txt
else
  echo "No matching repositories found for keyword '$keyword'."
fi
