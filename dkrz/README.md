# Setup and maintenance on DKRZ

The environment is managed with [pixi](https://pixi.sh) from [`../pixi.toml`](../pixi.toml).
Installation and Jupyter-kernel registration on DKRZ Levante are wrapped by
[`setup_dkrz_env.sh`](./setup_dkrz_env.sh), which keeps the env on `$HOME` (VAST), uses an
ephemeral package cache under `/scratch/<letter>/$USER`, and registers a kernel that activates
via `pixi run`. See the header of the script for the design rationale and source links.

## 1. Install pixi (one-time, per user)

```bash
curl -fsSL https://pixi.sh/install.sh | bash
echo 'export PATH="$HOME/.pixi/bin:$PATH"' >> ~/.bashrc
exec $SHELL -l
```

## 2. Install the environment + register the kernel

From the repo root on a Levante login node:

```bash
bash dkrz/setup_dkrz_env.sh
```

This solves and installs the env into `$HOME/pixi_envs/<repo>-<hash>/envs/default/`, then writes
`~/.local/share/jupyter/kernels/lagrangian-flood-analysis-thesis/kernel.json`. The kernel then
appears in [jupyterhub.dkrz.de](https://jupyterhub.dkrz.de) as **Pixi: lagrangian-flood-analysis-thesis**.

Use `--install-only` or `--register-kernel-only` to run just one half.

## 3. Update the environment (adding a package)

Edit `pixi.toml` (or use `pixi add <pkg>`), then re-run:

```bash
bash dkrz/setup_dkrz_env.sh --install-only
```

The wrapper re-installs with a fresh ephemeral cache; nothing persists on `/scratch` after it
exits. Bare `pixi add` calls outside the wrapper also fail safe: the setup script configures
pixi's global `cache.root` to point at `/scratch/<letter>/$USER/pixi-cache-default`, so no
package tarballs ever land in `$HOME`. The default `/scratch` directory is subject to DKRZ's
14-day idle purge, which is fine — re-download is cheap on DFN.

## 4. (Optional) Parcels tutorial notebooks and example data on `/work`

The Parcels v3 tutorial notebooks (`docs/user_guide/examples_v3/` in the Parcels repo) download
their example datasets via Parcels' `PARCELS_EXAMPLE_DATA` env var; by default that points into
`$HOME`. To keep notebooks and data on `/work` instead, with your project id substituted for
`<project>`:

```bash
PARCELS_VERSION=$(pixi list parcels | awk '/^parcels /{print $2; exit}')
DATA_DIR="/work/<project>/$USER/parcels-data-$PARCELS_VERSION"
SRC_DIR="/work/<project>/$USER/parcels-source-v$PARCELS_VERSION"
mkdir -p "$DATA_DIR"

git clone --branch "v$PARCELS_VERSION" --depth 1 \
  https://github.com/Parcels-code/Parcels "$SRC_DIR"

PARCELS_EXAMPLE_DATA="$DATA_DIR" pixi run python -c "
import parcels
for name in parcels.list_example_datasets():
    parcels.download_example_dataset(name)
"
```

Then add `"PARCELS_EXAMPLE_DATA": "$DATA_DIR"` (with the actual path) to the `env` block of
`~/.local/share/jupyter/kernels/lagrangian-flood-analysis-thesis/kernel.json` so the kernel
finds the data too.
