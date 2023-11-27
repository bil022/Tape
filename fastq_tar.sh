#!/bin/bash

if [ $# -lt 2 ]; then echo "Usage: $0 <dst> <src>..."; exit; fi    #if there are less than two inputs, show usage and exit

dst=$1    #record the destination
shift    #move to the next parameter

pl=${0%%sh}pl    #check if the corresponding .pl file exists
if ! [ -e $pl ]; then echo "$pl?"; exit; fi    #if not, print out the error and exit

du=`du -sk $* | awk '{n+=$1}END{print n}'`    ## ??? du -h --human-readable ??? ###the check source folder's size
df=`df -k . | awk '{n=$4}END{print n+1000}'`    ## ??? df -H ??? ###check the destination space availability

if [ $du -gt $df ]; then    ##if no enough space
  echo "Not enough space $du > $df"; exit;    ##print out the error and exit
fi

for dir in $*; do    #for each directory
  if ! [ -d $dir ]; then echo "dir? $dir"; exit; fi    #if the directory does not exist, print out the error and exit
  find $dir -mindepth 1 -maxdepth 1 -exec du -sk '{}' \;
done | $pl $dst
echo "echo $* done"

#[ -e tape_finder ] || git clone https://github.com/bil022/tape_finder
#bz2=tape_finder/$dst.find.txt.bz2
#echo "find $* -ls | bzip2 > $bz2"
#echo "rsync -av $bz2 $dst/."
#echo "pushd tape_finder; git add $bz2; git commit -m '$bz2'; git push; popd"
