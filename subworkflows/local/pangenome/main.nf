include { PANAROO_RUN } from '../../../modules/nf-core/panaroo/run/main.nf'
include { PLOTS_PANAROO } from '../../../modules/local/plots/panaroo/main.nf'
include { PPANGGOLIN_SAMPLE_TAB } from '../../../modules/local/ppanggolin/sample_tab/main.nf'
include { PPANGGOLIN_JOIN_TAB } from '../../../modules/local/ppanggolin/join_tab/main.nf'
include { PPANGGOLIN_RUN } from '../../../modules/local/ppanggolin/run/main.nf'

workflow PANGENOME {
    take:
    all_gffs
    sample_gff
    plots_metadata
    outdir

    main:
    panaroo_results = PANAROO_RUN(all_gffs)
    PLOTS_PANAROO(
        panaroo_results.results
            .map { meta, results -> 
                    def resultsDir = file(results[0]).getParent()
                    tuple( meta, file("${resultsDir}/gene_presence_absence.Rtab") ) },
        plots_metadata
    )

    sample_tab = PPANGGOLIN_SAMPLE_TAB( sample_gff, outdir )
    input_ppanggolin = PPANGGOLIN_JOIN_TAB( sample_tab.collect() )
    ppanggolin_results = PPANGGOLIN_RUN( input_ppanggolin )

    emit:
    panaroo_aln = panaroo_results.aln
}
