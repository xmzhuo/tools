#only for linux, not compatible with MacOS
#sep can not use space; can use character , ; or "\t"
tgrep(){
    #select by col_name
    #tgrep $input $col_name $sep $grep_option
    #selcol test.tsv .*_R , -v
    #echo "sed "s/${3}/\n/g""
    line_num=$(sed -n 1p $1 | sed "s/${3}/\n/g" | grep $4 $2 -n | sed 's/\:.*$//g')
    #echo $line_num
    sep=$(echo -e $3)
    #echo "cat $1 | cut -f $(echo $line_num | sed 's/ /,/g') -d $sep"
    cat $1 | cut -f $(echo $line_num | sed 's/ /,/g') $sep
    
}

file=$1
pattern=$2
sep=$3
add_cmd=$4
#echo "tgrep $file $pattern $sep $add_cmd"
tgrep $file $pattern $sep $add_cmd 
