from pathlib import Path

SNRNA_SUCCESS = Path(config['paths']['outdir']) / 'snrna' / '_SUCCESS'
SNRNA_REPO = config['external']['snrna_repo_dir']
RUN_EXT = bool(config['snrna']['run_external_module'])

rule snrna_external_module:
    input:
        rules.make_dirs.output
    output:
        touch("results/snrna/external_module/_SUCCESS")
    shell:
        r"
        set -euo pipefail
        if [ "{RUN_EXT}" != "True" ]; then
          echo 'snRNA external module disabled (snrna.run_external_module=false).'
          touch {output}
          exit 0
        fi

        test -d {SNRNA_REPO} || (echo 'Missing submodule: {SNRNA_REPO}' && exit 1)

        # This is intentionally a placeholder because Osman’s repo is script-driven.
        # Your lab can standardize a single entrypoint script and call it here.
        echo 'TODO: add a standardized entrypoint for snRNA external module.'
        touch {output}
        "

rule snrna_finalize:
    input:
        rules.make_dirs.output,
        "results/snrna/external_module/_SUCCESS"
    output:
        touch(str(SNRNA_SUCCESS))
    shell:
        r"touch {output}"
