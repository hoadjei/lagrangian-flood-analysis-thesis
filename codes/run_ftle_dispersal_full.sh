#!/bin/bash
#SBATCH --job-name=ftle_dispersal_full
#SBATCH --partition=compute
#SBATCH --mem=64G
#SBATCH --time=04:00:00              
#SBATCH --array=0-23%8             
#SBATCH --mail-type=FAIL
#SBATCH --account=bk1450
#SBATCH --output=ftle_dispersal_full.%A_%a.o   # %A = array job id, %a = task index

which pixi
echo $PWD

mkdir -p ../data/ftle_calc_and_plots
mkdir -p ../data/dispersal_and_connectivity

YEARS=(2020 2021 2022 2023 2024 2025)
WINDOWS=(5 10 20 30)

year_idx=$(( SLURM_ARRAY_TASK_ID / ${#WINDOWS[@]} ))
window_idx=$(( SLURM_ARRAY_TASK_ID % ${#WINDOWS[@]} ))
YEAR=${YEARS[$year_idx]}
n_days=${WINDOWS[$window_idx]}

echo "=== array task ${SLURM_ARRAY_TASK_ID}: window ${n_days}d, year ${YEAR} ==="

# 1) Full-year backward-FTLE sweep + panel plot
pixi run papermill \
    ftle_calc_and_plots.ipynb \
    ../data/ftle_calc_and_plots/ftle_calc_and_plots_${n_days}d_${YEAR}.ipynb \
    -p YEAR ${YEAR} \
    -p integration_days ${n_days} \
    -p integration_direction -1

# 2) Full-year forward dispersal sweep + aggregated connectivity + FTLE-shaded panel plot
pixi run papermill \
    dispersal_and_connectivity.ipynb \
    ../data/dispersal_and_connectivity/dispersal_and_connectivity_${n_days}d_${YEAR}.ipynb \
    -p YEAR ${YEAR} \
    -p integration_days ${n_days} \
    -p integration_direction 1
