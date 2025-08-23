include { PROKKA } from '../../../modules/nf-core/prokka/main.nf'
include { EGGNOGMAPPER } from '../../../modules/nf-core/eggnogmapper/main.nf'
include { ABRICATE_RUN } from '../../../modules/nf-core/abricate/run/main.nf'
include { ABRICATE_SUMMARY } from '../../../modules/nf-core/abricate/summary/main.nf'

workflow ANNOTATION {
    take:
    samples
    skip_eggnog

    main:
    prokka_results = PROKKA( samples, [], [] )
    all_gffs = prokka_results.gff
                .map{ meta, gff -> 
                        def newMeta = meta - meta.subMap(["id"])
                        tuple(newMeta, gff)
                }.groupTuple()

    if ( !skip_eggnog ) {
        EGGNOGMAPPER( prokka_results.faa, false, params.eggnog_data_dir, tuple( [], false ) )
    }

    abricate_results = ABRICATE_RUN( samples, [] )
    abricate_summary = ABRICATE_SUMMARY( 
        abricate_results.report
            .map{ meta, abricate -> 
                def newMeta = meta - meta.subMap(["id"])
                tuple(newMeta, abricate)
        }.groupTuple()
    )

    emit:
    all_gffs
    sample_gff = prokka_results.gff
    abricate_summary = abricate_summary.report
}
