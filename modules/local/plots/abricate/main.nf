process PLOTS_ABRICATE {
    tag "${params.genus}"
    conda "${moduleDir}/environment.yml"

    input:
    tuple val(meta), path(summary)
    tuple val(meta), path(tree_file)
    path metadata 

    output:
    tuple val(meta), path("*.png"), emit: plots
    path "versions.yml", emit: versions

    script:
    """
    plot_abricate.R ${summary} ${tree_file} ${metadata}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        R: \$(Rscript -e 'cat(paste0(R.Version()[c("major","minor")], collapse = "."))')
    END_VERSIONS
    """

    stub:
    """
    touch abricate_heatmap.png \\
        versions.yml
    """
}
