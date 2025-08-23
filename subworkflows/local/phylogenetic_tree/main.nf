include { GUBBINS } from '../../../modules/nf-core/gubbins/main.nf'
include { SNPSITES } from '../../../modules/nf-core/snpsites/main.nf'
include { IQTREE } from '../../../modules/nf-core/iqtree/main.nf'
include { PLOTS_TREE } from '../../../modules/local/plots/tree/main.nf'
include { PLOTS_ABRICATE } from '../../../modules/local/plots/abricate/main.nf'

workflow PHYLOGENETIC_TREE {
    take:
    panaroo_aln
    abricate_summary
    plots_metadata

    main:
    gubbins_results = GUBBINS( panaroo_aln.map { _meta, geneAlignment -> geneAlignment } )
    clean_aln = SNPSITES( gubbins_results.fasta )
    tree = IQTREE(
            clean_aln.fasta.map{ aln -> tuple([], aln, [])},
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            []
    )
    PLOTS_TREE( tree.phylogeny, plots_metadata )

    PLOTS_ABRICATE( abricate_summary, tree.phylogeny, plots_metadata )
}
