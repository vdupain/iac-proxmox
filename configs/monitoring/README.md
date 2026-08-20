# Monitoring Configs

Reference monitoring configurations exported from existing LXCs.

## Source

These configs are exported from the existing Proxmox LXCs that run the
current monitoring stack, before migrating to dedicated VMs.

| LXC | Host | Role | IP |
|-----|------|------|----|
| 105 | pve0 | - | - |
| 107 | pve2 | - | - |
| 113 | pve2 | - | - |

## Exported files

- `prometheus.yml` — Prometheus scrape configuration
- `alertmanager.yml` — Alertmanager routing and receiver configuration
- `grafana.ini` — Grafana server configuration

## Usage

These configs are the source of truth for what the new monitoring VMs
should run. The Terraform environment in `envs/monitoring/` provisions
the VMs; the actual config deployment is handled by Ansible or cloud-init
(see related provisioning code).

## Origin

Exported via `pct exec <CT_ID> cat <path>` from the respective LXC
as part of the migration to dedicated monitoring VMs on VLAN 50.