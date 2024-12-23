# *Automation Process: Fetch Git Repositories and Deploy with Argo CD*

This automation process uses *GitHub CLI (gh), *jq*, and **Argo CD CLI (argocd)* to:

1. *Fetch Git repositories* matching a keyword.
2. *Add repositories* to Argo CD.
3. *Deploy applications* to Kubernetes using Argo CD.

---

## *Prerequisites*

Before running the scripts, ensure the following tools are installed:

1. *GitHub CLI (gh)*
2. *jq* (JSON Processor)
3. *Argo CD CLI (argocd)*

---

## *1. Install Required Tools*

### *Install GitHub CLI (gh)*

Run the following commands to install GitHub CLI:

bash
type -p curl >/dev/null || (sudo apt update && sudo apt install -y curl)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh


Verify installation:

bash
gh --version


---

### *Install jq*

Run the following commands to install jq:

bash
sudo apt update
sudo apt install jq


Verify installation:

bash
jq --version


---

### *Install Argo CD CLI (argocd)*

Run the following commands to install the Argo CD CLI:

bash
VERSION=$(curl -L -s https://raw.githubusercontent.com/argoproj/argo-cd/stable/VERSION)
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/v$VERSION/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64


Verify installation:

bash
argocd version --client


---

## *2. Authenticate GitHub CLI*

Log in to GitHub using the GitHub CLI:

bash
gh auth login


Follow the prompts:

- Select *GitHub.com* as the platform.
- Use *HTTPS* for Git operations.
- Authenticate with a *web browser*.

---

## *3. Set Up Variables*

Create a file named *variables.txt* with the following variables:

bash
GIT_OWNER="your-github-organization-or-username"  # Replace with your GitHub organization or username
ARGOCD_SERVER="your-argocd-server:port"           # Replace with your ArgoCD server address
ARGOCD_USERNAME="admin"                           # Replace with ArgoCD username
ARGOCD_PASSWORD="your-argocd-password"            # Replace with ArgoCD password


Example:

bash
GIT_OWNER="penta55"
ARGOCD_SERVER="192.112.1.122:33333"
ARGOCD_USERNAME="admin2"
ARGOCD_PASSWORD="clPrjyKds6ghDaC1"


---

## *4. Fetch Git Repositories*

Run the script *fetchgiturls.sh* to fetch Git repositories based on a keyword:

bash
./fetchgiturls.sh


- You will be prompted to enter a keyword to search for repositories.
- The script fetches matching repository SSH URLs and saves them to *urls.txt*.

Example output:

plaintext
Enter a keyword to search in repository names: acc
Matching SSH URLs saved to urls.txt:
git@github.com:your-organization/repo-name.git


---

## *5. Add Repositories to Argo CD*

Run the script *addrepotoargo.sh* to add the fetched repositories to Argo CD:

bash
./addrepotoargo.sh


### What happens:
1. Prompts you to select an SSH key from your ~/.ssh directory.
2. Logs in to Argo CD using credentials from variables.txt.
3. Adds repositories from urls.txt to Argo CD.

---

## *6. Create Applications in Argo CD*

Run the script *createapplications.sh* to create applications in Argo CD:

bash
./createapplications.sh


### Script Prompts:
1. *Branch name* for the applications (e.g., main).
2. *Folder path* within the repository for Helm charts (e.g., charts).
3. *Namespace* to deploy the applications.

### What happens:
1. Logs in to Argo CD.
2. Iterates through urls.txt to create Argo CD applications.
3. Sets up automated sync policy.

Example:

plaintext
Enter the branch name for applications (e.g., main): main
Enter the folder path within each repo for the Helm chart (e.g., charts): charts
Enter the namespace for all applications: default


---

## *7. Verify Applications*

To check the status of created applications in Argo CD:

bash
argocd app list


You can also access the Argo CD web UI to verify deployments.

---


---

## *Final Notes*

- Ensure that your *SSH keys* are properly configured for accessing GitHub repositories.
- Make sure *Argo CD* is running and accessible on the specified server.

This automation simplifies the process of fetching repositories and deploying applications using Argo CD. 🚀