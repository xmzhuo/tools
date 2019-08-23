#only for linux, not compatible with MacOS
#sep can be use for various deliminator; such as "\t" for tab, "\s" for space
tgrep(){
    #select by col_name
    #tgrep $input $col_name $sep $grep_option
    #tgrep test.tsv "a|b" , -Ev
    if [ $3 == "\s" ];then 
        sep=" "
    else 
        sep=$(echo -e $3)
    fi
    
    line_num=$(sed -n 1p $1 | sed "s/${sep}/\n/g" | grep $4 $2 -n | sed 's/\:.*$//g')
    
    cat $1 | cut -f $(echo $line_num | sed 's/ /,/g') -d "$sep"
    
}

file=$1
pattern=$2
sep=$3
add_cmd=$4
#echo "tgrep $file $pattern $sep $add_cmd"
tgrep $file $pattern $sep $add_cmd 
