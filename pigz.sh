#!/bin/bash

for d in $*; do
  for f in `find $d -type f -exec ls -l {} + | sort -nrk7 | grep -v bam$ | grep -v gz$ | grep -v bz2$ | grep -v bw$ | awk '{print $NF}' | head -n 100`; do
    file=`./sfile -b $f`
    if [[ $file == *"text"* ]]; then
      echo "It's ASC."
    else
      echo "Not ASC"
    fi
    echo $f $file
  done
done
