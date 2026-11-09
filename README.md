# A feasibility boundary for attractor state transitions

Code and derived data for the manuscript *"A feasibility boundary for attractor
state transitions: when perturbation cannot drive learning, and where cortical
dynamics actually sit."*

Everything here runs on a single CPU core. No GPU, no cluster, no restricted
data access. A complete reproduction from the public data takes roughly one
hour, most of which is building the simulation library.

---

## What this repository contains

A closed-form theory of instructional state transitions in a hierarchical
phase-oscillator model, its numerical verification, a measurement model that
recovers latent coupling and noise from resting-state fMRI, and the empirical
analysis of 477 school-age participants from ABIDE I.

The central result is the **feasibility index**

```
Lambda = D_c / D_esc = D_c * log(T / tau_0) / dU_+
```

where `D_esc` is the noise intensity needed to leave a phase-locked attractor
within a session of duration `T`, and `D_c` is the largest noise intensity
compatible with assembly coherence. `Lambda <= 1` is an impossibility
statement: no perturbation, however tuned, can both dislodge the prior state
and preserve the integration that binding new content requires.

---

## Layout

```
code/      analysis and simulation pipeline (numbered in execution order)
data/      the Dosenbach-160 region-to-network mapping; ABIDE is fetched at run time
results/   every derived quantity reported in the manuscript
figures/   all figures as vector PDF and 600-dpi PNG
manuscript/ manuscript sources, tables, captions, reference list, DOCX
```

### Pipeline

| Script | What it does |
|---|---|
| `abn_core.py` | Observables and the closed-form theory (barriers, Kramers escape, critical coupling, feasibility index, entrainment time) |
| `abn_model.py` | Hierarchical Kuramoto forward model, rendering of region signals, library construction, inversion |
| `01_build_cohort.py` | Pre-specified cohort construction from the ABIDE phenotypic file |
| `02_extract_dynamics.py` | Streams ROI time series, computes observables |
| `03_estimator_validation.py` | Ground-truth benchmarks showing local drift estimators fail |
| `04_statistics.py` | Mixed models, FDR, permutation, leave-one-site-out, equivalence bounds |
| `05_invert.py` | Builds the simulation library, validates recovery, inverts participants |
| `06_theory.py` | Numerical verification of every closed form (parts A–F) |
| `07_protocols.py` | Simulation of the three instructional protocols |
| `08_surrogates.py` | Multivariate phase-randomised surrogate control |
| `09_figures.py` | All manuscript figures |
| `10_references.py` | Builds the reference list from registered Crossref metadata |
| `11_tables.py` | Builds the manuscript tables from the analysis outputs |
| `12_build_docx.js` | Assembles the manuscript DOCX |

---

## Reproducing

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
bash run_all.sh
```

`run_all.sh` executes the pipeline in order. Expected wall time on one core:

| Stage | Time |
|---|---|
| Cohort + observables (downloads ~480 runs) | ~2 min |
| Estimator validation | ~4 min |
| Theory verification (parts A–F) | ~25 min |
| Simulation library + inversion | ~20 min |
| Surrogates | ~4 min |
| Protocols | ~20 min |
| Statistics, tables, figures | ~5 min |

Every random seed is fixed. Re-running reproduces the reported numbers
exactly, apart from any change upstream in the public data.

### Partial reproduction

The theory is independent of the imaging data:

```bash
python code/06_theory.py          # all closed-form verifications
python code/07_protocols.py       # instructional protocol simulations
python code/09_figures.py 1 2 3   # theory figures
```

---

## Data

**No data are redistributed here beyond derived, participant-level summary
quantities.**

Resting-state derivatives and phenotypes come from ABIDE I as preprocessed by
the Preprocessed Connectomes Project, fetched directly from the public S3
bucket at run time:

```
https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/
  Phenotypic_V1_0b_preprocessed1.csv
  Outputs/cpac/nofilt_noglobal/rois_dosenbach160/<FILE_ID>_rois_dosenbach160.1D
```

No registration or data use certification is required for these derivatives.
ABIDE is released for non-commercial research use under a Creative Commons
Attribution-NonCommercial-ShareAlike licence; users of this repository must
honour those terms and cite the ABIDE and Preprocessed Connectomes Project
sources listed in `manuscript/references.md` (entries 36 and 37).

`results/` contains the exact retained participant identifiers, every
participant-level observable and latent parameter, the full statistical output
and all theory verification tables, so the statistics and figures can be
regenerated without re-downloading anything.

`results/library.csv.gz` is the simulation library (936 grid points x 3
replicates x 10 design cells). It is reproducible from `05_invert.py` but is
included so the inversion can be repeated without re-simulating.

### Two choices worth knowing about

- **`nofilt_noglobal`, not `filt_global`.** Global signal regression removes
  the spatially coherent component of the BOLD signal, which is exactly what
  the assembly order parameter measures. Using a global-signal-regressed
  derivative would bias every synchrony estimate towards zero.
- **0.04–0.07 Hz, applied here rather than inherited.** Instantaneous phase is
  only interpretable for a narrowband signal; the commonly used 0.01–0.1 Hz
  band is a full decade wide and does not satisfy that requirement.

---

## Honest limitations

These are stated in the manuscript and repeated here so that anyone reusing
the code knows what it does and does not establish.

- Resting-state data cannot observe learning. Baseline parameters are
  estimated and instruction is *modelled* as a transient coupling change.
- At five modules the assembly order parameter is dominated by finite-size
  fluctuations: `results/theory_B_collapse.csv` shows a floor near 0.48 even
  far below the synchronisation threshold.
- The inversion recovers assembly coupling moderately (Spearman rho = 0.58)
  and phase noise well (0.65); within-module coupling is weakly identified
  (0.36) and is not interpreted. Frequency dispersion was not identifiable and
  is held at a calibrated constant.
- The fitted barriers are shallow relative to the noise (median `dU/D` ≈ 0.11),
  which is outside the asymptotic regime of the Kramers law. Reported escape
  times are bounds, not accurate first-passage predictions.
- The empirical group contrasts are null and are reported as bounds, not as
  evidence of absence.
- The observables barely exceed stationary linear surrogates of the same data.
  Phase randomisation is a conservative null: failing to exceed it is
  informative, exceeding it would not by itself validate a measure.

---

## Licence

Code: MIT (see `LICENSE`).
Derived result files: CC BY 4.0, subject to the ABIDE non-commercial terms
described above and in `LICENSE-DATA.md`.

## Citation

See `CITATION.cff`.
