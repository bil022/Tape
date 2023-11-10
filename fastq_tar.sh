#!/bin/bash

if [ $# -lt 2 ]; then echo "Usage: $0 <dst> <src>..."; exit; fi

dst=$1
shift

pl=${0%%sh}pl
if ! [ -e $pl ]; then echo "$pl?"; exit; fi

for dir in $*; do
  if ! [ -d $dir ]; then echo "dir? $dir"; exit; fi
  find $dir -mindepth 1 -maxdepth 1 -exec du -sk '{}' \; | ./$pl $dst
done
