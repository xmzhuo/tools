#only for linux, not compatible with MacOS
#sep can be use for various deliminator; such as "\t" for tab, "\s" for space
#coice_of_line "0" for searching in all line; "1" for first line; "1,2" for 1 and 2 line
tgrepm(){
    #select by col_name
    #tgrepm $input $col_name $sep $choice_of_line $grep_option
    #tgrepm test.tsv "a|31" , "1,2" -E
    if [ $3 == "\s" ];then 
        sep=" "
    else 
        sep=$(echo -e $3)
    fi
    
    if [ $4 == "0" ]; then 
        row_num=$(cat $1 | wc -l)
        choice_line=""
        for((i=1; i<=$row_num; i++)); do choice_line=$(echo $choice_line $i);done 
    else
        choice_line=$(echo $4 | sed 's/,/ /g')
    fi

    line_num=""
    for i in $choice_line;do
    
        col_num=$(sed -n ${i}p $1 | sed "s/${sep}/\n/g" | grep $5 $2 -n | sed 's/\:.*$//g')
        line_num=$(echo $line_num $col_num)
        
    done
    chk=$(echo $line_num |wc -c)
    if [ $chk -gt 1 ]; then
        cat $1 | cut -f $(echo $line_num | sed 's/ /,/g') -d "$sep"
    fi
}

file=$1
pattern=$2
sep=$3
line=$4
add_cmd=$5

#echo "tgrep $file $pattern $sep $line $add_cmd"
tgrepm $file $pattern $sep $line $add_cmd 
