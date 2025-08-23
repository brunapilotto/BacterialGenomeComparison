include { ANNOTATION } from './subworkflows/local/annotation/main.nf'
include { PANGENOME } from './subworkflows/local/pangenome/main.nf'
include { PHYLOGENETIC_TREE } from './subworkflows/local/phylogenetic_tree/main.nf'

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
    
    annotation_results = ANNOTATION( metadata_ch, params.skip_eggnog )

    pangenome_results = PANGENOME(
        annotation_results.all_gffs,
        annotation_results.sample_gff,
        Channel.fromPath( params.plots_metadata ),
        params.outdir
    )

    PHYLOGENETIC_TREE(
        pangenome_results.panaroo_aln,
        annotation_results.abricate_summary,
        Channel.fromPath( params.plots_metadata )
    )
}
