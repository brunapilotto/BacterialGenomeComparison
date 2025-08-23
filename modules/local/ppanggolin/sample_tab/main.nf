process PPANGGOLIN_SAMPLE_TAB {
    tag "${meta.id}"

    input:
    tuple val(meta), path(gff)
    val outdir

    output:
    path "*.tab"

    script:
    def gffPath = file("${outdir}/Prokka/${meta.id}/${meta.id}.gff").toAbsolutePath()
    """
    echo -e "${meta.id}\t${gffPath}" > ${meta.id}.tab
    """

    stub:
    """
    touch ${meta.id}.tab
    """
}
