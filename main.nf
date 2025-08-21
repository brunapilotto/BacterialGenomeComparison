include { PROKKA } from './modules/nf-core/prokka/main.nf'
include { EGGNOGMAPPER } from './modules/nf-core/eggnogmapper/main.nf'
include { PANAROO_RUN } from './modules/nf-core/panaroo/run/main.nf'
include { PLOTS_PANAROO } from './modules/local/plots/panaroo/main.nf'
include { GUBBINS } from './modules/nf-core/gubbins/main.nf'
include { SNPSITES } from './modules/nf-core/snpsites/main.nf'
include { IQTREE } from './modules/nf-core/iqtree/main.nf'

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
    
    prokka_results = PROKKA( metadata_ch, false, false )

    if ( !params.skip_eggnog ) {
        eggnog_results = EGGNOGMAPPER( prokka_results.faa, false, params.eggnog_data_dir, tuple( [], false ) )
    }

    panaroo_results = PANAROO_RUN( 
                        prokka_results.gff
                            .map{ meta, gff -> 
                                    def newMeta = meta - meta.submap(["id"])
                                    tuple(newMeta, gff)
                            }.groupTuple()
                         )
    panaroo_plot = PLOTS_PANAROO( 
                    panaroo_results.results
                        .map { meta, results -> tuple( meta, file("${results}/gene_presence_absence.Rtab") ) },
                    params.plots_metadata
                )

    gubbins_results = GUBBINS( 
                        panaroo_results.aln.map { _meta, geneAlignment -> geneAlignment }
                    )
    clean_aln = SNPSITES( gubbins_results.fasta )
    tree = IQTREE(
            clean_aln.fasta.map{ aln -> tuple([], aln, false)},
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false
    )
}
