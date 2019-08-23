#only for linux, not compatible with MacOS
tgrep(){
    #select by col_name
    #tgrep $input $col_name $sep $grep_option
    #selcol test.tsv .*_R , -v
    line_num=$(sed -n 1p $1 | sed "s/${3}/\n/g" | grep $4 $2 -n | sed 's/\:.*$//g')
    #echo $line_num
    cat $1 | cut -f $(echo $line_num | sed 's/ /,/g') -d $3 
    
}

file=$1
pattern=$2
sep=$3
add_cmd=$4

tgrep $file $pattern $sep $add_cmd 
