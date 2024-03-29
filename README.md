<!-- badges: start -->
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/sanger-bentley-group/GBS_QC_nf)](https://github.com/sanger-bentley-group/GBS_QC_nf/releases)

[![pytest check](https://github.com/sanger-bentley-group/GBS_QC_nf/workflows/pytests_check/badge.svg)](https://github.com/sanger-bentley-group/GBS_QC_nf/actions)
<!-- badges: end -->

# GBS QC Nextflow Pipeline for farm5

## About

This pipeline provides QC information for lanes of Group B Strep (GBS) sequences that are imported on farm5 and QC-ed, assembled and mapped on `pf`. This pipeline gives:
- Relative abundance of GBS reads from Kraken
- Number of contigs
- GC content
- Genome length
- Coverage breadth
- Coverage depth
- Percentage HET SNPs out of total SNPs

## Installation

1. Download pipeline in a directory where you keep your software or pipelines:
```bash
git clone https://github.com/sanger-bentley-group/GBS_QC_nf.git
```


## Usage
1. Go into pipeline directory
```bash
cd GBS_QC_nf
```

2. Load nextflow module
```bash
module load nextflow
```

3. Run QC analysis using bsub:
```bash
bsub -o gbs_qc.%J.out -e gbs_qc.%J.err -R"select[mem>4000] rusage[mem=4000]" -M4000 'nextflow run main.nf --qc_reports_directory /path/to/gbs_qc_reports --lanes /path/to/gbs_lanes.txt'
```
Change:
- `/path/to/gbs_lanes.txt` to the file location of your list of lanes (that are imported and can be accessed via `pf`), e.g.

```bash
20280_5#1
20280_5#10
20280_5#100
20280_5#101
20280_5#102
20280_5#103
20280_5#104
20280_5#105
20280_5#106
20280_5#107
```

- `/path/to/gbs_qc_reports` to the directory location of the generated reports. (Default is the current directory)

## Output
You should get two tab-delimited output reports `qc_report_summary.txt` and `qc_report_complete.txt` in the `--qc_reports_directory` you specified. `qc_report_summary.txt` gives the `lane_id` and PASS/FAIL `status`. `qc_report_complete.txt` gives all the PASS/FAIL status for each QC.

### Missing Data
In `qc_report_summary.txt`, if there are empty values:
- `rel_abundance` then these lanes may not have been imported/imported properly with a kraken report. _Solution: Contact `path-help@sanger.ac.uk` to import those lanes again_
- `contig_no`, `gc_content` or `genome_len` then these lanes may not have been assembled/assembled properly. _Solution: Check the status of the assemblies using the `pf status` command. If `-`, contact `path-help@sanger.ac.uk` to assemble those lanes. If `Failed`/`Running`/`Pending`, ask path-help to re-trigger the assemblies again (Although `Failed` assemblies can suggest a problem with the read coverage)_
- `cov_breadth` or `cov_depth` then these were not calculated in `pf`. _Solution: Contact `path-help@sanger.ac.uk` to ask why these values for these lanes are not available in `pf data -s`._
- `HET_SNPs` then these lanes may not have had SNPs called. _Solution: Check the status of the SNP call using `pf status` command. If `-`, contact `path-help@sanger.ac.uk` to call SNPs. If `Failed`/`Running`/`Pending`, ask path-help to re-trigger call SNPs again._

## Additional options
    --rel_abund_threshold           Pass read QC if rel_abundance is > rel_abund_threshold. (Default: 70)
    --species                       Species of interest. (Default: 'Streptococcus agalactiae')
    --contig_no_threshold           Pass contig number QC if contig_no < contig_no_threshold. (Default: 500)
    --assembler                     Assemblies of interest e.g. velvet or spades. (Default: spades)
    --gc_content_lower_threshold    QC content must be >= gc_content_lower_threshold to pass. (Default: 32)
    --gc_content_higher_threshold   QC content must be <= gc_content_higher_threshold to pass. (Default: 38)
    --genome_len_lower_threshold    Genome length/total number of bases > genome_len_lower_threshold to pass. (Default: 1450000)
    --genome_len_higher_threshold   Genome length/total number of bases < genome_len_higher_threshold to pass. (Default: 2800000)
    --cov_depth_threshold           Genome depth of coverage > cov_depth_threshold to pass. (Default: 20)
    --cov_breadth_threshold         Genome breadth of coverage > cov_breadth_threshold to pass. (Default: 70)
    --het_snps_threshold            Number of HET SNPs <= het_snps_threshold to pass. (Default: 20)

## The methods
The methods used for finding relative abundance from Kraken, coverage breadth, coverage depth and percentage HET SNPs out of total SNPs are described [here](http://mediawiki.internal.sanger.ac.uk/index.php/Pathogen_Informatics_QC_Pipeline) (Sanger access only).

### For developers

To run Python unit tests:
```
pytest tests
```

To test this pipeline on the farm:
```
module load nextflow/20.10.0-5430
bsub -G <YOUR GROUP> -o gbs_qc.o -e gbs_qc.e -R"select[mem>4000] rusage[mem=4000]" -M4000 'nextflow run main.nf --qc_reports_directory gbs_qc_report --lanes tests/test_data/test_lanes.txt'
```
