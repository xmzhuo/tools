#!/bin/bash
#
# Modified for paralization by Ming
# example
#bash get_analysis_costs_dnanexus-aws_fast.sh <date after> <date before> <number of thread>
#bash get_analysis_costs_dnanexus-aws_fast.sh 2018-11-01 2018-11-15 16

# This script will find all analyses in a project for a specific date range
# and output the analysis ID, folder(includes sample name), analysis that was run,
# the user who started the analysis, the cost, pass/fail status of the analysis
# and the date finished with the run time
#
#
# Run this script like this:
# bash script.sh <created after date> <created before date>
# where date format is in the form YYYY-MM-DD

###### function #######

my_fun() {
    #function line that need to be parallelized
    dx describe $1 | grep -E '^ID|^Job name|^Region|^Billed to|^Instance Type|^State|^Parent analysis|^Output folder|^Launched by|^Created|^Started running|^Stopped running|^Total Price' 
}

my_par() {
    #my_par input_job_list output thread_num
    joblist=$1
    thread_n=$3
    output=$2
    total_job=$(cat $1 | wc -l)
    rm $output -f 
    i=0
    #loop trhough the jobs to retrieve information of interest in parallel with (up to n threads)
    for a in $(cat $joblist); do
        
        #fetch the information of interest
        if [ : ]; then
            
            echo "job_launch for $a"
            my_fun $a >> $output
            #dx describe $a | grep -E '^ID|^Job name|^Region|^Billed to|^Instance Type|^State|^Parent analysis|^Output folder|^Launched by|^Created|^Started running|^Stopped running|^Total Price' \
            #| tee -a ./dx_jobs/dx_jobs_$1_$2.txt | grep "State" 
            echo "job_finish for $a"

        fi &
        
        #check how many job launch and finish so far
        job_launch=$(grep "^job_launch for" my_par_screen.log| wc -l)
        job_finish=$(grep "^job_finish for" my_par_screen.log| wc -l)
        i=$(awk -v var=$i 'BEGIN{print var+1}')
        #check point to cap the maximum thread according to defined number, 
        #check how many jobs finish every 1 second, if one finish launch the n+1 job, keep the cpu running n jobs until all of them finish
        while :;
            do
            job_finish=$(grep "^job_finish for" my_par_screen.log| wc -l)  
            thread_triger=$(awk -v var1="$i" -v var2="$job_finish" 'BEGIN{print (var1-var2)}') 
            if [ "$thread_triger" -lt "$thread_n" ]; then echo "total $total_job; launched $job_launch; finished $job_finish; current process ${i}th, start ${i}+1"; break; fi
            sleep 1
        done
        
    done | tee -a my_par_screen.log 
    #| grep -E "launched.*00; finishes"
    rm my_par_screen.log
}



############ main code #############
#make a new directory "dx_jobs" in current folder
mkdir dx_jobs
rm my_par_screen.log
#looking for jobs in allprojects that before and after a certain range of time and save them to a new file "jobs"
dx find jobs --created-after $1 --created-before $2 --allprojects -n 1000000 --brief > ./dx_jobs/jobs
total_job=$(cat ./dx_jobs/jobs |wc -l)
#predefined the thread number from input 
thread_num=$3
echo "$thread_n threads"



my_par ./dx_jobs/jobs ./dx_jobs/dx_jobs_$1_$2.txt $thread_num

#grep "^fail" screen.log | sed 's/fail to fetch //' > fail.list

# for analyses (workflows)
#for a in $analyses; do
#dx describe $a --json | jq '.id' -r >> ${a}.txt
#dx describe $a --json | jq '.folder' -r >> ${a}.txt
#dx describe $a --json | jq '.executableName' -r >> ${a}.txt
#dx describe $a --json | jq '.launchedBy' -r >> ${a}.txt
#dx describe $a --json | jq '.totalPrice' -r >> ${a}.txt
#dx describe $a --json | jq '.stateTransitions[].newState' -r >> ${a}.txt
#dx describe $a | grep '^Finished' >> ${a}.txt
#done
