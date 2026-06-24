# Ansible Guide

## What Ansible Does Here

Ansible configures the software inside the containers and VMs that Terraform created. After `terraform apply` provisions a bare Debian LXC, Ansible connects over SSH and installs packages, hardens the system, and deploys services.

Ansible does **not** create or destroy infrastructure — that is Terraform's job.

## How Ansible Works (Mental Model)

Ansible connects to remote machines over SSH and runs tasks on them. There is no agent installed on the target — Ansible pushes instructions from your laptop and executes them remotely using Python (which is pre-installed on Debian).

A **playbook** is a list of tasks written in YAML. A **role** is a reusable collection of tasks, templates, and default variables that can be called from multiple playbooks. A **task** is a single action — install a package, write a file, restart a service.

Each task uses a **module** — a built-in Ansible function. For example:
- `ansible.builtin.apt` installs packages on Debian
- `ansible.builtin.copy` copies a file to the remote machine
- `ansible.builtin.service` starts, stops, or restarts a service
- `ansible.builtin.template` renders a Jinja2 template and writes it to the remote machine

## Directory Structure

```
ansible/
  ansible.cfg                    ← Ansible configuration (inventory path, SSH settings)
  inventory/
    hosts.yml                    ← real inventory (gitignored — contains live IPs)
    hosts.yml.example            ← example inventory committed to the repo
    group_vars/
      all.yml                    ← variables that apply to every host
      cyberark.yml               ← variables specific to CyberArk hosts
  roles/
    common/                      ← base setup: packages, timezone, motd
    ssh-hardening/               ← SSH config, 2FA, fail2ban
    firewall/                    ← UFW rules
    docker/                      ← Docker CE installation
    nginx/                       ← Nginx reverse proxy
  playbooks/
    observability.yml            ← applies common + docker roles to observability LXC
    harden.yml                   ← applies ssh-hardening + firewall to any host
    cyberark-prep.yml            ← Windows prerequisites for CyberArk VMs
```

## Inventory

The inventory tells Ansible which machines exist and how to reach them. This project uses a YAML inventory.

`hosts.yml` is gitignored because it contains real IP addresses of running containers. `hosts.yml.example` is what is committed — it shows the structure without real values:

```yaml
# hosts.yml.example
all:
  children:
    observability:
      hosts:
        obs01:
          ansible_host: 192.168.30.10
          ansible_user: debian
    cyberark:
      hosts:
        ca-vault:
          ansible_host: 192.168.40.10
          ansible_user: Administrator
        ca-pvwa:
          ansible_host: 192.168.40.11
          ansible_user: Administrator
```

After `terraform apply` assigns an IP to a new container, copy the example, fill in the real IP, and Ansible can reach it.

## Roles

Each role has a standard directory structure created by `ansible-galaxy init`:

```
roles/common/
  tasks/
    main.yml      ← list of tasks that run when the role is applied
  defaults/
    main.yml      ← default variable values (lowest priority — easily overridden)
  handlers/
    main.yml      ← tasks triggered by notify (e.g. restart nginx after config change)
  templates/
    *.j2          ← Jinja2 templates rendered and copied to the remote machine
  meta/
    main.yml      ← role metadata (author, dependencies)
```

### common
Runs on every Linux host. Sets the timezone, installs baseline packages (curl, vim, htop, unattended-upgrades), and writes a login banner (MOTD) to the machine.

### ssh-hardening
Tightens SSH configuration: disables root login, disables password authentication (key-only), sets an idle timeout, and installs fail2ban to block brute-force attempts.

### firewall
Installs UFW and applies a default-deny inbound policy with explicit allow rules per host group. Outbound traffic is allowed by default.

### docker
Installs Docker CE from Docker's official apt repository (not the Debian default repository, which ships an older version). Used by the observability LXC to run Prometheus and Grafana as containers.

### nginx
Installs Nginx and writes a reverse proxy configuration from a Jinja2 template. The template uses variables from `group_vars` so the same role can proxy different backends depending on which host it runs on.

## Running a Playbook

```bash
# From the repo root on WSL

# Run the full observability stack
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/observability.yml

# Run hardening only against all hosts
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/harden.yml

# Run against a single host
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/harden.yml --limit obs01

# Dry run — show what would change without making changes
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/observability.yml --check
```

## Idempotence

Every Ansible task is written to be idempotent — running the same playbook twice produces the same result as running it once. If a package is already installed, Ansible skips it. If a config file already matches the template, Ansible skips it.

This matters for two reasons:
1. You can re-run a playbook safely at any time to enforce the desired state
2. The second run should report zero changes — if it does not, a task is not idempotent and needs to be fixed

## Secrets with Ansible Vault

Sensitive values (passwords, API keys) are encrypted using Ansible Vault and committed to the repo in encrypted form. They are decrypted at runtime using a vault password stored in an environment variable.

```bash
# Encrypt a single value
ansible-vault encrypt_string 'mysecretvalue' --name 'db_password'

# Run a playbook with vault decryption
ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass ansible-playbook ...
# or
ansible-playbook --ask-vault-pass ...
```

The vault password file (`~/.vault_pass`) lives outside the repo and is never committed.

## Installing Ansible on WSL

```bash
sudo apt update
sudo apt install pipx
pipx install --include-deps ansible

# Verify
ansible --version
```

Installing via `pipx` is preferred over `apt` because it gives you the latest stable version in an isolated Python environment, avoiding conflicts with system Python packages.
