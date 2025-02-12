//
// MARKDUPLICATES AND QC after mapping
//

include { CRAM_QC_MOSDEPTH_SAMTOOLS } from '../cram_qc_mosdepth_samtools/main'
include { GATK4_MARKDUPLICATES      } from '../../../modules/nf-core/gatk4/markduplicates/main'

workflow BAM_MARKDUPLICATES_GATK4 {

    take:
    bam                    // channel: [mandatory] [ meta, bam ]
    fasta                  // channel: [mandatory] [ fasta ]
    fasta_fai              // channel: [mandatory] [ fasta_fai ]
    intervals_bed_combined // channel: [optional]  [ intervals_bed ]


    main:

    versions = Channel.empty()
    reports  = Channel.empty()
 
    // RUN MARKUPDUPLICATES
    BAM_MARKDUPLICATES_GATK4(bam, fasta, fasta_fai)

    // Join with the crai file
    cram = BAM_MARKDUPLICATES_GATK4.out.cram.join(BAM_MARKDUPLICATES_GATK4.out.crai, failOnDuplicate: true, failOnMismatch: true)

    // QC on CRAM
    CRAM_QC_MOSDEPTH_SAMTOOLS(cram, fasta, intervals_bed_combined)

    // Gather all reports generated
    reports = reports.mix(BAM_MARKDUPLICATES_GATK4.out.metrics)
    reports = reports.mix(CRAM_QC_MOSDEPTH_SAMTOOLS.out.reports)

    // Gather versions of all tools used
    versions = versions.mix(BAM_MARKDUPLICATES_GATK4.out.versions)
    versions = versions.mix(CRAM_QC_MOSDEPTH_SAMTOOLS.out.versions)   

    emit:    
    cram
    reports

    versions // channel: [ versions.yml ]
}

