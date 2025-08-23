include { PROKKA } from './modules/nf-core/prokka/main.nf'
include { EGGNOGMAPPER } from './modules/nf-core/eggnogmapper/main.nf'
include { GUBBINS } from './modules/nf-core/gubbins/main.nf'
include { SNPSITES } from './modules/nf-core/snpsites/main.nf'
include { IQTREE } from './modules/nf-core/iqtree/main.nf'
include { PLOTS_TREE } from './modules/local/plots/tree/main.nf'

include { PANGENOME } from './subworkflows/local/pangenome/main.nf'

include { validateParameters; paramsSummaryLog; samplesheetToList } from 'plugin/nf-schema'
validateParameters()

log.info """\
Pipeline Bacterial Genome Comparison
===================================
""".stripIndent()
log.info paramsSummaryLog(workflow)

workflow {
    parsed_input_csv = Channel.fromList( samplesheetToList( params.metadata, "assets/schema_input.json" ) )
    metadata_ch = parsed_input_csv.map { sample, fasta  -> tuple ( [ id: sample, genus: params.genus ], fasta ) }
    
    prokka_results = PROKKA( metadata_ch, [], [] )
    all_gffs = prokka_results.gff
                .map{ meta, gff -> 
                        def newMeta = meta - meta.subMap(["id"])
                        tuple(newMeta, gff)
                }.groupTuple()

    if ( !params.skip_eggnog ) {
        eggnog_results = EGGNOGMAPPER( prokka_results.faa, false, params.eggnog_data_dir, tuple( [], false ) )
    }

    pangenome_results = PANGENOME(
        all_gffs,
        prokka_results.gff,
        Channel.fromPath( params.plots_metadata ),
        params.outdir
    )

    gubbins_results = GUBBINS( 
                        pangenome_results.panaroo_aln.map { _meta, geneAlignment -> geneAlignment }
                    )
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
    tree_plot = PLOTS_TREE(
                    tree.phylogeny,
                    Channel.fromPath( params.plots_metadata )
                )
}
