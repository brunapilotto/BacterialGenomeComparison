process VIRSORTER {
    tag "${meta.id}"
    conda "bioconda::virsorter=2.2.4"
    container "quay.io/biocontainers/virsorter:2.2.4--pyhdfd78af_2"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("${meta.id}"), emit: results_folder
    path "versions.yml", emit: versions

    script:
        def args = task.ext.args ?: ''
        """
        virsorter setup -d db -j ${task.cpus}
        virsorter run -w ${meta.id} -i ${fasta} -j ${task.cpus} $args

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            virsorter: \$(echo \$(virsorter --version 2>&1) | sed 's/^.*virsorter //')
        END_VERSIONS
        """

    stub:
        """
        mkdir ${meta.id}
        touch versions.yml
        """
}
