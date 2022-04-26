process percentage_HET_SNPs {

    input:
    path lanes_file

    output:
    path "${output_file}"

    script:
    pf_version=params.pf_version
    output_file="all_stats.tar"
    """
    #!/bin/bash

    module load pf/${pf_version}
    pf snp -t file -i ${lanes_file} | grep .gz\$ > vcf_files.txt

    num=\$(cat vcf_files.txt | wc -l)

    for ((i=1;i<=\${num};i++))
    do
        vcf_file=\$(sed -n "\${i}p" vcf_files.txt)
        lane=\$(sed -n "\${i}p" ${lanes_file})

        a1=\$(zcat<\${vcf_file} | awk -F'\t' 'NR==100{print \$1}')
        gunzip -c \${vcf_file} > tmp.vcf
        filtervcf_v4.py tmp.vcf \${lane} 50
    done
    tar -cf ${output_file} *stats
    """
}
