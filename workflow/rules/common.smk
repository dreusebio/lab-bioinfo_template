import pandas as pd
from pathlib import Path

SAMPLESHEET = config["paths"]["samplesheet"]
samples_df = pd.read_csv(SAMPLESHEET, sep="\t", dtype=str)

def outdir():
    return config["paths"]["outdir"]

def logdir():
    return config["paths"]["logdir"]

def assay():
    return config["project"]["assay"]

def apath(*parts):
    return str(Path(outdir()) / assay() / Path(*parts))

rule make_dirs:
    output:
        touch(apath("_DIRS_CREATED"))
    shell:
        r"
        mkdir -p {config[paths][outdir]}/{config[project][assay]}
        mkdir -p {config[paths][logdir]}/{config[project][assay]}
        touch {output}
        "
