# Lagrangian Flood Analysis

This repository hosts the codes and data documentation for the master's Thesis: Hydrodynamic Pathways of Flood-Event Runoff in the Cabo Verde Region: Implications for Island Connectivity and Marine Ecosystem Response.

## Setup and maintenance on DKRZ

The environment is managed with [pixi](https://pixi.sh) from [`pixi.toml`](./pixi.toml).
Installation and Jupyter-kernel registration on DKRZ Levante are wrapped by
[`dkrz_helpers/setup_dkrz_env.sh`](./dkrz_helpers/setup_dkrz_env.sh), which keeps the env on
`$HOME` (VAST), uses an ephemeral package cache under `/scratch/<letter>/$USER`, and registers a
kernel that activates via `pixi run`. See the header of the script for the design rationale and
source links.

### 1. Install pixi (one-time, per user)

```bash
curl -fsSL https://pixi.sh/install.sh | bash
echo 'export PATH="$HOME/.pixi/bin:$PATH"' >> ~/.bashrc
exec $SHELL -l
```

### 2. Install the environment + register the kernel

From the repo root on a Levante login node:

```bash
bash dkrz_helpers/setup_dkrz_env.sh
```

This solves and installs the env into `$HOME/pixi_envs/<repo>-<hash>/envs/default/`, then writes
`~/.local/share/jupyter/kernels/lagrangian-flood-analysis-thesis/kernel.json`. The kernel then
appears in [jupyterhub.dkrz.de](https://jupyterhub.dkrz.de) as **Pixi: lagrangian-flood-analysis-thesis**.

Use `--install-only` or `--register-kernel-only` to run just one half.

### 3. Update the environment (adding a package)

Edit `pixi.toml` (or use `pixi add <pkg>`), then re-run:

```bash
bash dkrz_helpers/setup_dkrz_env.sh --install-only
```

The wrapper re-installs with a fresh ephemeral cache; nothing persists on `/scratch` after it
exits. Bare `pixi add` calls outside the wrapper also fail safe: the setup script configures
pixi's global `cache.root` to point at `/scratch/<letter>/$USER/pixi-cache-default`, so no
package tarballs ever land in `$HOME`. The default `/scratch` directory is subject to DKRZ's
14-day idle purge, which is fine — re-download is cheap on DFN.
