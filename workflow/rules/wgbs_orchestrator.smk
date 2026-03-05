from pathlib import Path

WGBS_SUCCESS = Path(config['paths']['outdir']) / 'wgbs' / '_SUCCESS'

EPIGEN_DIR = config['external']['epigenerator_dir']
EPIGEN_PROFILE = config['wgbs']['preprocess']['profile']
EPIGEN_JOBS = int(config['wgbs']['preprocess']['jobs'])
EPIGEN_STD_OUT = config['wgbs']['preprocess']['standardized_outdir']

COMETHYL_ON = bool(config['wgbs']['downstream']['run_comethyl'])
DMRICHR_ON = bool(config['wgbs']['downstream']['run_dmrichr'])

COMETHYL_OUT = config['comethyl']['outdir']
DMRICHR_OUT = config['dmrichr']['outdir']

rule wgbs_epigenerator:
    input:
        rules.make_dirs.output
    output:
        touch("results/wgbs/epigenerator/_SUCCESS")
    resources:
        time_min=1440,
        mem_mb=64000,
        threads=8
    shell:
        r"
        set -euo pipefail
        # Run epigenerator pipeline (expects user to configure epigenerator itself)
        # NOTE: You must init submodules first:
        #   git submodule update --init --recursive
        test -d {EPIGEN_DIR} || (echo 'Missing submodule: {EPIGEN_DIR}' && exit 1)

        # If epigenerator has its own working dir/config, you can either:
        #  (A) configure epigenerator to write directly into {EPIGEN_STD_OUT}
        #  (B) run it in-place then rsync outputs into {EPIGEN_STD_OUT}
        #
        # This template uses (B) as the safe default.
        mkdir -p {EPIGEN_STD_OUT}

        (cd {EPIGEN_DIR} && snakemake --profile ../../{EPIGEN_PROFILE} -j {EPIGEN_JOBS})

        # TODO: Adjust this rsync once you standardize epigenerator output paths in your lab.
        # Example:
        # rsync -av {EPIGEN_DIR}/CpG_Me2/output/ {EPIGEN_STD_OUT}/
        echo 'NOTE: configure rsync path from epigenerator outputs -> standardized results dir.'
        touch {output}
        "

rule wgbs_comethyl:
    input:
        rules.wgbs_epigenerator.output
    output:
        touch("results/wgbs/comethyl/_SUCCESS")
    conda:
        "workflow/envs/r_comethyl.yaml"
    shell:
        r"
        set -euo pipefail
        Rscript workflow/scripts/wgbs/run_comethyl.R \
          --epigenerator_dir '{EPIGEN_STD_OUT}' \
          --coldata_xlsx '{config[wgbs][coldata_xlsx]}' \
          --outdir '{COMETHYL_OUT}' \
          --covMin '{config[comethyl][params][covMin]}' \
          --methSD '{config[comethyl][params][methSD]}'
        touch {output}
        "

rule wgbs_dmrichr:
    input:
        rules.wgbs_epigenerator.output
    output:
        touch("results/wgbs/dmrichr/_SUCCESS")
    conda:
        "workflow/envs/r_dmrichr.yaml"
    shell:
        r"
        set -euo pipefail
        Rscript workflow/scripts/wgbs/run_dmrichr.R \
          --epigenerator_dir '{EPIGEN_STD_OUT}' \
          --coldata_xlsx '{config[wgbs][coldata_xlsx]}' \
          --outdir '{DMRICHR_OUT}' \
          --maxPerms '{config[dmrichr][params][maxPerms]}'
        touch {output}
        "

rule wgbs_finalize:
    input:
        rules.make_dirs.output,
        rules.wgbs_epigenerator.output,
        # Conditionally include downstream sentinels
        *( ["results/wgbs/comethyl/_SUCCESS"] if COMETHYL_ON else [] ),
        *( ["results/wgbs/dmrichr/_SUCCESS"] if DMRICHR_ON else [] )
    output:
        touch(str(WGBS_SUCCESS))
    shell:
        r"
        touch {output}
        "
