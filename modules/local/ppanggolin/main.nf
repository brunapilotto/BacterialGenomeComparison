process PPANGGOLIN {
    tag "${params.genus}"
    conda "bioconda::ppanggolin=2.2.4"
    container "quay.io/biocontainers/ppanggolin:2.2.4--h1fe012e_0"

    input:
        tuple val(meta), path(gffs)
        path(gff_tab)

    output:
        tuple val(meta), path("ppanggolin_output*"), emit: results_folder
        tuple val(meta), path("ppanggolin_output*/pangenomeGraph_light.gexf"), emit: graph
        path("versions.yml"), emit: versions

    script:
        """
        ppanggolin workflow --anno ${gff_tab}

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            ppanggolin: \$(echo \$(ppanggolin --version 2>&1) | sed 's/^.*ppanggolin //' ))
        END_VERSIONS
        """

    stub:
        """
        mkdir ppanggolin_output_some_date
        touch versions.yml \\
            ppanggolin_output_some_date/pangenomeGraph_light.gexf
        """
}
