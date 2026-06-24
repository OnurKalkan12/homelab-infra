# Terraform Guide

## What Terraform Does Here

Terraform creates and destroys the containers and VMs on Proxmox. You write a description of what you want (an LXC container with 3 GB RAM on VLAN 30), run `terraform apply`, and Terraform talks to the Proxmox API to make it real. When you're done, `terraform destroy` removes everything cleanly.

Terraform does **not** configure the software inside the containers — that is Ansible's job.

## Provider

This repo uses the [`bpg/proxmox`](https://registry.terraform.io/providers/bpg/proxmox/latest) provider. It is the most actively maintained Terraform provider for Proxmox VE and supports the full VM and LXC lifecycle.

The provider is declared in `providers.tf` (not yet written — this doc is ahead of the code). When you run `terraform init`, Terraform downloads the provider binary from the Terraform Registry into the `.terraform/` directory. This directory is gitignored — the provider is never committed.

## Module Structure

```
modules/
  lxc/       ← reusable module for LXC containers
  vm/        ← reusable module for full VMs
  network/   ← bridge and VLAN definitions (apply once, never destroy)

envs/
  observability.tfvars   ← variables for the observability environment
  cyberark.tfvars        ← variables for the CyberArk environment
```

**Why modules?**
Without modules, you would repeat the same Terraform resource blocks for every environment. The `lxc/` module defines what an LXC container looks like once. Each environment just calls that module with different values (different RAM, different IP, different VLAN). This is the same reason you write functions in code instead of repeating logic.

**Why `.tfvars` files per environment?**
Each environment has different values — different RAM allocation, different IP address, different VLAN tag. Keeping those values in separate `.tfvars` files means the module code never changes; only the inputs change when you switch environments.

## State

Terraform keeps a file called `terraform.tfstate` that records everything it created on Proxmox — resource IDs, IP addresses, metadata. This is how Terraform knows what already exists when you run `plan` or `destroy`.

**Critical rules:**
- The state file is gitignored — it never goes into the repository
- Do not delete it manually while resources are still running on Proxmox — Terraform will lose track of what it created
- If the state file is lost while resources exist, they become orphaned and must be manually removed from Proxmox or re-imported

For this homelab, state is local (stored on your laptop in the project directory). A future improvement would be remote state storage using Terraform Cloud, which makes the state accessible from any machine and adds locking to prevent concurrent applies.

## Authentication

Terraform connects to Proxmox using an API token — not your root password. The token is stored in an environment variable, never in code.

```bash
# Set before running any terraform command
export PM_API_TOKEN_ID="terraform@pve!homelab"
export PM_API_TOKEN_SECRET="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

How to create the token: see [scripts/bootstrap.sh](../scripts/bootstrap.sh).

The `providers.tf` file reads these from environment variables. Anyone who clones this repo must create their own token — yours is never committed.

## Apply Workflow

CI (GitHub Actions) runs `terraform validate` and `terraform plan` automatically on every pull request. **Apply is always manual, run from WSL on your local laptop.**

This is intentional. The Proxmox API is only reachable on the local network — GitHub-hosted runners have no access to it. Apply stays local until a self-hosted runner is configured inside the network.

```bash
# Full workflow for any environment
terraform init                                      # first time only
terraform plan  -var-file="envs/observability.tfvars"   # review what will be created
terraform apply -var-file="envs/observability.tfvars"   # create it
```

Always review the `plan` output before applying. The plan shows exactly what Terraform will create, modify, or destroy — no surprises.

## Network Module — Apply Once

The `modules/network/` module defines the Proxmox bridges (`vmbr0`, `vmbr1`) and VLAN configuration. This is applied **once during initial setup** and is never destroyed.

```bash
# Run this once when setting up the Proxmox host for the first time
terraform apply -var-file="envs/network.tfvars"
# Do not run terraform destroy against the network module
```

All other environments depend on these bridges existing. Destroying the network module while any container or VM is running would break connectivity.

## Switching Environments

Only one environment should be active at a time given the 16 GB RAM constraint.

```bash
# Tear down the current environment
terraform destroy -var-file="envs/observability.tfvars"

# Bring up a different one
terraform apply -var-file="envs/cyberark.tfvars"
```

`terraform destroy` removes every resource declared in the matching `.tfvars` scope — containers, VMs, their disks. The Proxmox host and the network bridges are unaffected.

## Installing Terraform on WSL

```bash
# Add HashiCorp's package repository
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install terraform

# Verify
terraform version
```
