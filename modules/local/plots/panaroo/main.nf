process PLOTS_PANAROO {
    debug params.debug
    tag "${meta.client_name}:${meta.id}:${meta.marker}"
    conda 'conda-forge::r-base=4.5.1'
    container 'docker.io/r-base:4.5.1'

    input:
        tuple val(meta), path(gene_presence_absence)

    output:
        tuple val(meta), path("*png"), emit: plots
        path("versions.yml")         , emit: versions

    script:
        """
        plots_panaroo.R ${gene_presence_absence}

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            R: \$(Rscript -e 'cat(paste0(R.Version()[c("major","minor")], collapse = "."))')
        END_VERSIONS
        """

    stub:
        """
        touch hist_plot_panaroo.png \\
            pie_plot_panaroo.png \\
            versions.yml
        """
}
