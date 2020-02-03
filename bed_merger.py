#python bed_merger.py test.bed 0.5 for merging 50% of segment length 
#python bed_merger.py test.bed 50 for merging segment within 50bp distance
# 
# merge multiple segement within a given distance, by a given length (integer) or by a fraction of neighboring segments (float)
# if copy number change dup or del different in column 6, it will not skip the new segment to merge with the next one. 
# also correct the direction if strand is reverse "-" 

import pandas as pd
import numpy as np
import math
import time
import re
import sys
#bed filename
f1name=sys.argv[1]
#min length for merge two segment, integer as bp in lenght; float as fraction of a length.
minlen=sys.argv[2]
if "." in minlen:
    minlen = float(minlen)
else:
    minlen = int(minlen)

f1name_re=re.sub('bed','',f1name)

print(f1name_re)

try:
    f1hand=open(f1name)
    print(f1name)
except:
    print('Input file bed no exist')

df = pd.read_csv(f1name, sep ='\t', names=["chr","start","end","strand","number","value"])
df.shape
df.head()
print(df)

#if strand is "-", rearrange start and end
strand_start = df['start'].copy()
strand_end = df['end'].copy()
strand_new = df['strand'].copy()
strand_end[df['strand'] == "-"] = df['start'][df['strand'] == "-"]
strand_start[df['strand'] == "-"] = df['end'][df['strand'] == "-"] 
strand_new[df['strand'] == "-"] = "+" 
df['start'] = strand_start
df['end'] = strand_end
df['strand'] = strand_new

if isinstance(minlen,int):
    print(minlen," is integer; used as fixed length")
    start_border = df ['start'] - int(minlen) / 2
    end_border = df ['end'] + int(minlen) / 2
else:
    print(minlen," is float; used as dynamic length as fraction of segment")
    min_len = (df['end'] - df['start']) * float(minlen)
    start_border = df ['start'] - min_len
    end_border = df ['end'] + min_len

df['start_border'] = start_border
df['end_border'] = end_border
print(df)
#print(df.shape[0])

new_chr = [] 
new_start = [] 
new_end = [] 
new_strand = [] 
new_number = [] 
new_value = []
temp_number = 0
for index, row in df.iterrows():
    #print(index)
    #if index not last one;
    #if chr is the same
    #if value or CNV type the same
    #if the range overlap with next segment
    #else call an segment end
    temp_number += df['number'][index]
    if index < (df.shape[0] - 1):
        if df['chr'][index] == df['chr'][index + 1] and df['value'][index] == df['value'][index + 1] and df['end_border'][index] >= df['start_border'][index + 1]:
            temp = df['start'][index]
            #temp_number += df['number'][index] 
        else:
            if index == 0:
                temp_start = df['start'][index]
                #temp_number = df['number'][index]
            #temp_number += df['number'][index]
            new_chr.append(df['chr'][index])
            new_start.append(temp_start)
            new_end.append(df['end'][index])
            new_strand.append(df['strand'][index])
            new_number.append(temp_number)
            new_value.append(df['value'][index])
            temp_start = df['start'][index + 1]
            temp_number = 0
    else:
        new_chr.append(df['chr'][index])
        new_start.append(temp_start)
        new_end.append(df['end'][index])
        new_strand.append(df['strand'][index])
        new_number.append(temp_number)
        new_value.append(df['value'][index])

new_data = {'chr':new_chr,'start':new_start,'end':new_end,'strand':new_strand,'number':new_number,'value':new_value}
new_df = pd.DataFrame (new_data, columns = ['chr','start','end','strand','number','value'])
print(new_df)

new_df.to_csv(f1name_re+'merge.bed',sep='\t',header=False, index=False)


