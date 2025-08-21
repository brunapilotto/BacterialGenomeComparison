# 🦠 BacterialGenomeComparison

[![Nextflow DSL2](https://img.shields.io/badge/Nextflow%20DSL2-%E2%89%A524.04.2-23aa62.svg?logo=nextflow&logoColor=30a969&style=flat)](https://www.nextflow.io/docs/latest/install.html)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=5c5c5c&logo=docker)](https://docs.docker.com/engine/install/ubuntu/)
[![run with conda](https://img.shields.io/badge/run%20with-conda-3EB049?labelColor=5c5c5c&logo=anaconda)](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html)
[![Monitor on Seqera Platform](https://img.shields.io/badge/Monitor%20%F0%9F%9A%A8-Seqera%20Platform-ee8cff?logo=seqera&logoColor=fff)](https://cloud.seqera.io/)

## 📋 Description

**BacterialGenomeComparison** is a pipeline developed with **Nextflow** designed to compare genomes of bacteria of the same species from different sources using pre-selected tools.

---

## 🚀 Features

- Using [ABRicate](https://github.com/tseemann/abricate) to mass screening of contigs for antimicrobial resistance or virulence genes.
- Using [Easyfig](https://mjsull.github.io/Easyfig/) to create linear comparison figures of multiple genomic loci.
- Using [eggNOG-mapper](https://github.com/eggnogdb/eggnog-mapper) to functional annotation through orthology assignment.
- Using [Gubbins](https://github.com/nickjcroucher/gubbins) for detection of recombination in the alignment.
- Using [panaroo](https://github.com/gtonkinhill/panaroo) to pangenome investigation.
- Using [SNP-sites](https://sanger-pathogens.github.io/snp-sites/) to extract SNPs from a multi-FASTA alignment.
- Using [Pokka](https://github.com/tseemann/prokka) to genome annotation.
- Fully compatible with **Nextflow** for scalable and reproducible workflows.
- Support for execution environments using **Docker** or **Conda**.
- Production of auxiliary files: **DAG**, **timeline**, and **trace**.
- Automatic parameter validation via **nf-schema**.

---

## 🖥️ Standard Execution

> [!NOTE]
> Before running the pipeline, make sure you have all dependencies in your machine (check [Requirements](#️-requirements)).

```bash
nextflow run BacterialGenomeComparison/main.nf \\
  --metadata organism.csv \\
  --genus Escherichia
```

This command will run the pipeline with docker. If you want to use Conda:

```bash
nextflow run BacterialGenomeComparison/main.nf \\
  --metadata organism.csv \\
  --genus Escherichia \\
  -profile conda
```

---

## ⚙️ Pipeline Parameters

| **Parameter**             | **Description**                                         | **Required?**                      |
| --------------------------| --------------------------------------------------------|------------------------------------|
| `anaconda_base`           | Path to Conda base env                                  | No (default: `/opt/anaconda3`)     |
| `--eggnog_data_dir`       | Path to store eggNOG-mapper databases                   | No (default: `~/eggnog_data`)      |
| `--genus`                 | Genus of the organism                                   | Yes                                |
| `--metadata`              | Path to the samplesheet with input samples              | Yes                                |
| `--nextflow_reports`      | Path to the folder that will store the pipeline reports | No (default: `./pipeline_reports`) |
| `--outdir`                | The output directory where the results will be saved    | No (default: `./results`)          |
| `--plots_metadata`        | Path to the tsv metadata file for panaroo plotting      | Yes                                |
| `--skip_eggnog`           | Skip Eggnog step                                        | No (default: `false`)              |

If you want to know all the pipeline parameters, you can run the command:

```bash
nextflow run BacterialGenomeComparison/main.nf --help
```

If you want more information about a specific parameter, you can run the command:

```bash
nextflow run BacterialGenomeComparison/main.nf --help param
```

Parameters different from the default can be specified at the command line.

Example:

```bash
nextflow run BacterialGenomeComparison/main.nf \\
  --metadata organism.csv \\
  --genus Escherichia \\
  --outdir files
```

---

## 🧹 After finishing

Once the pipeline is finished, you can check the results in the outdir folder.

For **good practice**, it is recommended to delete the last run analysis in Nextflow work diretory, so once you finish the analysis, you can remove the last run files from the folder.

Ex: if your Nextflow work directory is `/tmp/nextflow/`, you can use the following command:

```bash
rm -rf /tmp/nextflow/
```

> [!WARNING]
> Be careful! If the pipeline was stopped by an error, do not delete the information on this folder, because the `-resume` option needs this information to continue executions that were stopped by an error. Only delete it if the pipeline was completed with no error, and you are not running other basecall.

---

## 🛠️ Requirements

- **[Nextflow](https://www.nextflow.io/docs/latest/install.html)**
- **[Conda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html)**
- **[Docker](https://docs.docker.com/engine/install/ubuntu/)**
- **Tower config**: you can monitor your pipeline execution in [Seqera Cloud](https://cloud.seqera.io/) page. To do this, you must have an account, access token and workspace ID, which need to be specified at the `tower.config` file in the `conf/` folder.

    ```groovy
    tower {
        enabled     = true
        accessToken = "token"
        workspaceId = "ID"
    }
    ```

---
