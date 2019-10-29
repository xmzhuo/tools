# convert vcf file to csv file
# only for linux, not compatible with MacOS


vcf2csv(){
    ## produce table of all content:# vcf2csv abc.vcf.gz 
    ## prepare table for ML, integer/float only:# vcf2csv abc.vcf.gz ML
    vcf_file=$1
    add_req=$2
    #echo $vcf_file $add_req
    vcf_name=$(echo $vcf_file | sed 's/\.*$//g')
    rm -f *temp.txt
    #Head_COMMON="%CHROM %POS %ID %REF %ALT %QUAL %FILTER"

    Head_COMMON=$(zcat $vcf_file | grep "^#CHROM" | sed 's/\tINFO.*$//g' | sed 's/^#/\%/g' | sed 's/\t/\ \%/g')

    Head_COMMON_num=$(echo $Head_COMMON | awk -F '%' '{print NF-1}')
    #echo $Head_COMMON
    HEAD_NAME=$(bcftools query -l $vcf_file )

    #if [ $add_req == "ML" ]; then
    if [ -z $add_req ]; then
        add_req=""
        #covert all content for csv
        Head_INFO=$(echo $(zcat $vcf_file | grep "^##INFO" |sed 's/^.*\<ID=/\%INFO\//g'|sed 's/\,.*$//g'))
        #%INFO/AC %INFO/AF %INFO/AN %INFO/BaseQRankSum %INFO/ClippingRankSum %INFO/DB %INFO/DP %INFO/END %INFO/ExcessHet %INFO/FS %INFO/InbreedingCoeff %INFO/MLEAC %INFO/MLEAF %INFO/MQ %INFO/MQRankSum %INFO/QD %INFO/RAW_MQ %INFO/ReadPosRankSum %INFO/SOR

        Head_FORMAT=$(echo $(zcat $vcf_file |grep "^##FORMAT" |sed 's/^.*\<ID=/\[\ \%/g'|sed 's/\,.*$/]/g')| sed 's/\] /]/g')
        #[ %AD][ %DP][ %GQ][ %GT][ %MIN_DP][ %PGT][ %PID][ %PL][ %RGQ][ %SB]
        zcat $vcf_file|grep "^##FORMAT" |sed 's/^.*\<ID=/\%/g'|sed 's/\,.*$//g' > temp.txt

        touch all-temp.txt
        #zcat $vcf_file|grep "^##FORMAT" |sed 's/^.*\<ID=/\%/g'|sed 's/\,.*$//g' > temp.txt
        for HEAD_NAME_TEMP in $HEAD_NAME; do
            #echo $HEAD_NAME_TEMP
            sed "s/^/$HEAD_NAME_TEMP/g" temp.txt > $HEAD_NAME_TEMP-temp.txt
            cp all-temp.txt all1-temp.txt
            paste all1-temp.txt $HEAD_NAME_TEMP-temp.txt > all-temp.txt
        done
        #echo $Head_COMMON $Head_INFO$(cat all-temp.txt) | sed 's/ /\,/g' > $vcf_name.${add_req}vcf2csv.temp.csv
        echo $Head_COMMON $Head_INFO$(cat all-temp.txt) | sed 's/ /\,/g'
        rm *temp.txt
        #bcftools query -f "$Head_COMMON $Head_INFO$Head_FORMAT\n" $vcf_file | sed 's/\,/|/g' | sed 's/ /\,/g' >> $vcf_name.${add_req}vcf2csv.temp.csv
        bcftools query -f "$Head_COMMON $Head_INFO$Head_FORMAT\n" $vcf_file | sed 's/\,/|/g' | sed 's/ /\,/g' 
    else
        add_req="ML_"
        #prepare matrics table for ML 
        Head_INFO=$(echo $(zcat $vcf_file | grep -Ew "Type=Integer|Type=Float" | grep "^##INFO" |sed 's/^.*\<ID=/\%INFO\//g'|sed 's/\,.*$//g'))
        #Head_INFO=$(echo $(zcat $vcf_file | grep -Ew "Number=1|Number=A" | grep -Ew "Type=Integer|Type=Float" | grep "^##INFO" |sed 's/^.*\<ID=/\%INFO\//g'|sed 's/\,.*$//g'))
        #%INFO/AC %INFO/AF %INFO/AN %INFO/BaseQRankSum %INFO/ClippingRankSum %INFO/DB %INFO/DP %INFO/END %INFO/ExcessHet %INFO/FS %INFO/InbreedingCoeff %INFO/MLEAC %INFO/MLEAF %INFO/MQ %INFO/MQRankSum %INFO/QD %INFO/RAW_MQ %INFO/ReadPosRankSum %INFO/SOR

        #Head_FORMAT=$(echo $(zcat $vcf_file | grep -Ew "Type=Integer|Type=Float" | grep "^##FORMAT" |sed 's/^.*\<ID=/\[\ \%/g'|sed 's/\,.*$/]/g')| sed 's/\] /]/g')
        Head_FORMAT=$(echo $(zcat $vcf_file | grep -Ew "Number=1|Number=A" | grep -Ew "Type=Integer|Type=Float" | grep "^##FORMAT" |sed 's/^.*\<ID=/\[\ \%/g'|sed 's/\,.*$/]/g')| sed 's/\] /]/g')
        #Head_FORMAT_m=$(echo $(zcat $vcf_file | grep -Ew "Number=R|Number=G" | grep -Ew "Type=Integer|Type=Float" | grep "^##FORMAT" |sed 's/^.*\<ID=/\[\ \%/g'|sed 's/\,.*$/]/g')| sed 's/\] /]/g')
        Head_FORMAT_m=$(echo $(zcat $vcf_file | grep -Ew "Number=R" | grep -Ew "Type=Integer|Type=Float" | grep "^##FORMAT" |sed 's/^.*\<ID=/\[\ \%/g'|sed 's/\,.*$/]/g')| sed 's/\] /]/g')

        zcat $vcf_file | grep -Ew "Number=1|Number=A" | grep -Ew "Type=Integer|Type=Float" | grep "^##FORMAT" |sed 's/^.*\<ID=/\%/g'|sed 's/\,.*$//g' > temp.txt
        #zcat $vcf_file | grep -Ew "Number=R|Number=G" | grep -Ew "Type=Integer|Type=Float" | grep "^##FORMAT" |sed 's/^.*\<ID=/\%/g'|sed 's/\,.*$//g' |awk '{print $1"_R",$1"_A"}' > s_temp.txt
        zcat $vcf_file | grep -Ew "Number=R" | grep -Ew "Type=Integer|Type=Float" | grep "^##FORMAT" |sed 's/^.*\<ID=/\%/g'|sed 's/\,.*$//g' |awk '{print $1"_R",$1"_A"}' > s_temp.txt
        #paste -c " " s_temp.txt s_temp.txt > s2_temp.txt
        
        touch all-temp.txt
        touch all-2temp.txt
        #zcat $vcf_file|grep "^##FORMAT" |sed 's/^.*\<ID=/\%/g'|sed 's/\,.*$//g' > temp.txt
        i=0
        for HEAD_NAME_TEMP in $HEAD_NAME; do
            #echo $HEAD_NAME_TEMP
            i=$(expr $i + 1)
            sed "s/^/$i/g" temp.txt > $HEAD_NAME_TEMP-temp.txt
            cp all-temp.txt all1-temp.txt
            paste all1-temp.txt $HEAD_NAME_TEMP-temp.txt > all-temp.txt
            
            #sed "s/^/$HEAD_NAME_TEMP/g" s_temp.txt > $HEAD_NAME_TEMP-2temp.txt
            awk -v var=$i '{print var$1,var$2}' s_temp.txt > $HEAD_NAME_TEMP-2temp.txt
            cp all-2temp.txt all1-2temp.txt
            paste all1-2temp.txt $HEAD_NAME_TEMP-2temp.txt > all-2temp.txt

        done

        #echo $Head_COMMON $Head_INFO$(cat all-temp.txt)$(cat all-2temp.txt) | sed 's/ /\,/g' > $vcf_name.${add_req}vcf2csv.temp.csv
        echo $Head_COMMON $Head_INFO$(cat all-temp.txt)$(cat all-2temp.txt) | sed 's/ /\,/g' 
        rm *temp.txt
        #bcftools query -f "$Head_COMMON $Head_INFO$Head_FORMAT$Head_FORMAT_m\n" $vcf_file | sed 's/\,/ /g' | sed 's/ /\,/g' >> $vcf_name.${add_req}vcf2csv.temp.csv
        bcftools query -f "$Head_COMMON $Head_INFO$Head_FORMAT$Head_FORMAT_m\n" $vcf_file | sed 's/\,/ /g' | sed 's/ /\,/g' 
    fi
    #cat $vcf_name.${add_req}vcf2csv.temp.csv
    #rm *temp.csv
}

vcffile=$1
addreq=$2
#echo $vcffile $addreq
vcf2csv $vcffile $addreq



