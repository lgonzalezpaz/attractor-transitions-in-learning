#!/usr/bin/env bash
# Full reproduction. Seeds are fixed; re-running reproduces the reported numbers.
set -euo pipefail
cd "$(dirname "$0")"
export PYTHONHASHSEED=0
P=${PYTHON:-python3}

echo "== 1/9  cohort =============================================="
$P code/01_build_cohort.py

echo "== 2/9  observables (downloads ABIDE derivatives) ============"
$P code/02_extract_dynamics.py nofilt_noglobal dynamics.csv
$P - <<'PY'
import pandas as pd
d = pd.read_csv('results/dynamics.csv'); d = d[d.status == 'ok']
d = d[(d.n_tp_used >= 100) & (d.duration_s >= 220)]
g = d.groupby(['SITE_ID', 'group']).size().unstack(fill_value=0)
bad = g[(g.get('ASD', 0) < 3) | (g.get('TD', 0) < 3)].index.tolist()
d = d[~d.SITE_ID.isin(bad)]
d.to_csv('results/dynamics_qc.csv', index=False)
print('retained', len(d), d.group.value_counts().to_dict())
PY

echo "== 3/9  estimator validation ================================="
$P code/03_estimator_validation.py

echo "== 4/9  theory verification =================================="
$P code/06_theory.py A B C D E F

echo "== 5/9  simulation library and inversion ====================="
$P code/05_invert.py

echo "== 6/9  surrogate control ===================================="
$P code/08_surrogates.py

echo "== 7/9  instructional protocols =============================="
$P code/07_protocols.py

echo "== 8/9  statistics and tables ================================"
$P code/04_statistics.py
$P code/11_tables.py

echo "== 9/9  figures =============================================="
$P code/09_figures.py 1 2 3 4 5 6 7

echo
echo "Done. Figures in figures/, derived quantities in results/."
