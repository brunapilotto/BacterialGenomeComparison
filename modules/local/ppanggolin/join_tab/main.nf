process PPANGGOLIN_JOIN_TAB {
    tag "${params.genus}"

    input:
    path samples_tabs

    output:
    path "*.tab"

    script:
    """
    cat ${samples_tabs} > prokka.gff.tab
    """

    stub:
    """
    touch prokka.gff.tab
    """
}
