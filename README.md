# LAB_SNAKEMAKE_TEMPLATE

Lab-standard **Snakemake orchestrator** template.

## What this template does

### WGBS (recommended path)
1) **epigenerator** (submodule) for preprocessing / cytosine reports
2) downstream analysis:
   - **Comethyl** (R script wrapper)
   - **DMRichR** (R script wrapper)

### snRNA
- Optional: pinned analysis repo as a **submodule** + wrapper rule(s)

### WGS
- Placeholder stub (extend as your lab standardizes a WGS pipeline)

## Setup

Clone a project created from this template, then initialize submodules:
```bash
git submodule update --init --recursive
```

## Configure
- `config/config.yaml`
- `config/samples.tsv`
- metadata lives in `metadata/`

## Run
Dry-run:
```bash
snakemake -n
```

Local:
```bash
snakemake --profile workflow/profiles/local
```

Slurm:
```bash
snakemake --profile workflow/profiles/slurm -j 100
```

## Conventions
- Generated outputs: `results/` (not committed)
- Logs: `logs/` (not committed)
- Human metadata + provenance: `metadata/` (committed)
