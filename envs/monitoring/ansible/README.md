# Monitoring stack — Ansible deployment

This directory contains the Ansible playbook that configures the monitoring
stack **after** the VMs have been provisioned by Terraform.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                   VLAN 50 (192.168.50.0/24)          │
│                                                      │
│  ┌──────────────────────┐    ┌──────────────────────┐│
│  │  monitoring-grafana  │    │ monitoring-prometheus ││
│  │  192.168.50.248      │    │ 192.168.50.249       ││
│  │                      │    │                      ││
│  │  node_exporter :9100 │    │  node_exporter :9100 ││
│  │                      │◄───►│  Prometheus  :9090   ││
│  └──────────────────────┘    └──────────────────────┘│
└─────────────────────────────────────────────────────┘
```

## What it does

- **On both VMs**: Installs Prometheus `node_exporter` v1.8.2 as a systemd
  service on port 9100, exposing host metrics (`/metrics`).
- **On the Prometheus VM** (192.168.50.249): Installs Prometheus v2.55.1
  configured to scrape node_exporter from both VMs every 15s.
- **Verification**: Each task validates the service is running and serving
  data before proceeding.

## Prerequisites

- The two VMs must exist and be reachable on VLAN 50 (provisioned by
  `envs/monitoring/` Terraform config).
- SSH access to both VMs using the `monitoring` user and the SSH key
  configured in Terraform.
- Ansible >= 2.16 installed on the control node.

## Usage

### 1. Apply the playbook

```bash
cd envs/monitoring/ansible
ansible-playbook -i inventory.yml playbooks/site.yml
```

### 2. Verify the stack

| Component       | URL                                     | Expected result      |
|-----------------|-----------------------------------------|----------------------|
| Node exporter   | `http://192.168.50.248:9100/metrics`    | Plain text metrics   |
| Node exporter   | `http://192.168.50.249:9100/metrics`    | Plain text metrics   |
| Prometheus      | `http://192.168.50.249:9090/targets`    | Both targets UP      |
| Prometheus API  | `http://192.168.50.249:9090/api/v1/...` | JSON status response |

### 3. Health check (quick)

```bash
# Quick node_exporter health
curl -s http://192.168.50.248:9100/metrics | head -5

# Quick Prometheus health
curl -s http://192.168.50.249:9090/-/healthy

# Check targets in Prometheus
curl -s http://192.168.50.249:9090/api/v1/targets \
  | jq '.data.activeTargets[] | {job, health, instance}'
```

## Variables

All variables are defined in `group_vars/all.yml`. Key configuration:

| Variable                       | Default     | Description                          |
|--------------------------------|-------------|--------------------------------------|
| `node_exporter_version`        | `1.8.2`     | Node exporter release version        |
| `node_exporter_port`           | `9100`      | Node exporter listening port         |
| `prometheus_version`           | `2.55.1`    | Prometheus release version           |
| `prometheus_port`              | `9090`      | Prometheus listening port            |
| `prometheus_retention_days`    | `30`        | Metrics retention period             |
| `prometheus_scrape_targets`    | (see vars)  | Scrape jobs for Prometheus           |

## Idempotency

The playbook is fully idempotent — running it multiple times produces the
same result. Binary downloads are cached by Ansible's `get_url` module
(e.g. `/tmp/node_exporter-1.8.2.linux-amd64.tar.gz`).

## Upgrading components

1. Update the version in `group_vars/all.yml` (e.g. `node_exporter_version`
   or `prometheus_version`).
2. Re-run the playbook — Ansible detects the version mismatch and
   re-downloads the new binary, then restarts the service.

## Troubleshooting

- **"Failed to connect to the host via ssh"**: Ensure the VM is running and
  the SSH key is loaded (`ssh-add -l`).
- **"Port 22: Connection refused"**: The VM may still be booting. Wait
  30-60s after Terraform apply and retry.
- **node_exporter service fails to start**: Check `systemctl status
  node_exporter` on the VM. The binary may need execute permissions or a
  newer glibc.
- **Prometheus targets show DOWN**: Verify node_exporter is running on both
  VMs and that VLAN 50 routing allows traffic between them.