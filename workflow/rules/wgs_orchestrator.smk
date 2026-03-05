from pathlib import Path
WGS_SUCCESS = Path(config['paths']['outdir']) / 'wgs' / '_SUCCESS'

rule wgs_stub:
    input:
        rules.make_dirs.output
    output:
        touch("results/wgs/_SUCCESS")
    shell:
        r"
        echo 'WGS stub. Implement lab-standard WGS pipeline here.'
        touch {output}
        "
