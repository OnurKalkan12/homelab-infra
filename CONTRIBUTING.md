# Contributing

Contributions are welcome — bug reports, improvements to documentation, and fixes to Terraform or Ansible code.

## Getting Started

```bash
git clone https://github.com/your-username/homelab-infra.git
cd homelab-infra

# Install Terraform (see docs/TERRAFORM.md)
# Install Ansible and collections
pip install ansible ansible-lint
ansible-galaxy collection install -r ansible/requirements.yml
```

## Before Opening a Pull Request

**Terraform:**
```bash
terraform fmt -recursive
terraform init -backend=false
terraform validate
```

**Ansible:**
```bash
cd ansible && ansible-lint
```

Both checks run automatically in CI on every PR. A PR with failing checks will not be merged.

## Scope

This is a personal homelab project. Changes that improve reusability, fix bugs, or improve documentation are in scope. Changes that add project-specific configuration (IP addresses, personal credentials, employer-specific tooling) are out of scope.

## Code Style

- Terraform: standard `terraform fmt` formatting, no exceptions
- Ansible: FQCN module names (`ansible.builtin.apt`, not `apt`), explicit `mode:` on all file tasks
- No hardcoded IP addresses or credentials anywhere in committed files
