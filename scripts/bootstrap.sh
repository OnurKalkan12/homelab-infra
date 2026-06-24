#!/usr/bin/env bash
# bootstrap.sh — One-time Proxmox setup for Terraform access.
#
# Run this directly on the Proxmox host as root:
#   ssh root@YOUR_PROXMOX_IP
#   bash bootstrap.sh
#
# What this script does:
#   1. Creates a dedicated Proxmox role with the permissions Terraform needs
#   2. Creates a dedicated Terraform user (terraform@pve)
#   3. Grants the role to the user
#   4. Creates an API token and prints it — copy it now, it is shown only once

set -euo pipefail

ROLE_NAME="TerraformRole"
USER_NAME="terraform@pve"
TOKEN_NAME="homelab"
NODE_NAME="${1:-pve}"   # pass your node name as argument if it differs from "pve"

echo ""
echo "==> [1/4] Creating role: ${ROLE_NAME}"
pveum role add "${ROLE_NAME}" \
  --privs "VM.Allocate,VM.Clone,VM.Config.Disk,VM.Config.CPU,VM.Config.Memory,\
VM.Config.Network,VM.Config.Options,VM.Config.CDROM,VM.PowerMgmt,\
Datastore.AllocateSpace,Datastore.AllocateTemplate,Datastore.Audit,\
Sys.Audit,Sys.Modify,SDN.Use" \
  2>/dev/null && echo "    Created." || echo "    Already exists — skipping."

echo ""
echo "==> [2/4] Creating user: ${USER_NAME}"
pveum user add "${USER_NAME}" --comment "Terraform homelab automation" \
  2>/dev/null && echo "    Created." || echo "    Already exists — skipping."

echo ""
echo "==> [3/4] Granting role on / (root) and /nodes/${NODE_NAME}"
pveum aclmod / \
  --users "${USER_NAME}" \
  --roles "${ROLE_NAME}"

# Network bridge management requires Sys.Modify at the node level specifically
pveum aclmod "/nodes/${NODE_NAME}" \
  --users "${USER_NAME}" \
  --roles "${ROLE_NAME}"

echo "    Done."

echo ""
echo "==> [4/4] Creating API token: ${TOKEN_NAME}"
echo ""
echo "    ┌─────────────────────────────────────────────────────────────┐"
echo "    │  COPY THE TOKEN SECRET BELOW — IT IS SHOWN ONLY ONCE       │"
echo "    └─────────────────────────────────────────────────────────────┘"
echo ""

pveum user token add "${USER_NAME}" "${TOKEN_NAME}" --privsep 0

echo ""
echo "==> Done. Paste the token into your .tfvars file as:"
echo ""
echo "    proxmox_api_token = \"${USER_NAME}!${TOKEN_NAME}=PASTE_SECRET_HERE\""
echo ""
echo "==> Next steps:"
echo "    1. Copy the token secret above into your .tfvars file"
echo "    2. Add these routes in WSL so your laptop can reach containers:"
echo "       sudo ip route add 192.168.30.0/24 via YOUR_PROXMOX_IP"
echo "       sudo ip route add 192.168.40.0/24 via YOUR_PROXMOX_IP"
echo "    3. Run: terraform init"
echo "    4. Run: terraform plan -var-file=\"envs/observability.tfvars\""
