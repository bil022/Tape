#!/bin/bash

if [ $# -lt 2 ]; then echo "Usage: $0 <dst> <src>..."; exit; fi

dst=$1
shift

pl=${0%%sh}pl
if ! [ -e $pl ]; then echo "$pl?"; exit; fi

du=`du -g $* | awk '{print $1}'`
df=`df -g . | awk '{n=$4}END{print n+1}'`

if [ $du -gt $df ]; then
  echo "Not enough space $du > $df"; exit;
fi

[ -e tape_finder ] || git clone https://github.com/bil022/tape_finder
echo "find $* -ls | gzip > tape_finder/$dst.find.txt.gz"
echo "rsync -av tape_finder/$dst.find.txt.gz $dst/."
echo "pushd tape_finder; git add $dst.find.txt.gz; git commit -m '$dst.find.txt.gz'; git push; popd"

for dir in $*; do
  if ! [ -d $dir ]; then echo "dir? $dir"; exit; fi
  find $dir -mindepth 1 -maxdepth 1 -exec du -sk '{}' \; | $pl $dst
done
