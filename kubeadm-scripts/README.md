# Kubernetes Node Setup Guide

Take care of the following when setting up Kubernetes nodes:

1. **Network Interface**: Update the script to use the correct network interface (e.g., `eth0`, `ens160`). Use `ifconfig` to identify the appropriate interface.

2. **Hostname**: Set a unique hostname for each node to avoid conflicts.

3. **Prerequisites**: Ensure the server runs Ubuntu, has `sudo` privileges, and swap is disabled.

4. **Kubeadm Reset**: If `kubeadm` has been used previously, the script will reset it. Verify Kubernetes-related files are cleaned up if needed.

5. **Version Compatibility**: Ensure the specified CRI-O and Kubernetes versions are compatible with your cluster.

6. **Firewall**: Open necessary ports for Kubernetes communication.

