#!/usr/bin/env bash

for day in {12..22}; do
    echo $day
    papermill 010_lcs_map.ipynb 010_lcs_map_2025-08-${day}.ipynb -p reference_time "2025-08-${day}" -k python &
    sleep 1
done

wait