#!/bin/bash

if [ $# -lt 2 ]; then echo "Usage: $0 <dst> <src>..."; exit; fi

dst=$1
shift

pl=${0%%sh}pl
if ! [ -e $pl ]; then echo "$pl?"; exit; fi

du=`du -g $* | awk '{print $1}'`
df=`df -g $* | awk '{n=$4}END{print n}'`

if [ $du -gt $df ]; then
  echo "Not enough space $du > $df"; exit;
fi

for dir in $*; do
  if ! [ -d $dir ]; then echo "dir? $dir"; exit; fi
  find $dir -mindepth 1 -maxdepth 1 -exec du -sk '{}' \; | $pl $dst
done
