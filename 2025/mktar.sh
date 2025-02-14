#!/bin/bash

usr=anthony
for n in `seq -f "%02g" 0 10`; do
  date; echo begin ${usr} $n
  tar -cf ../${usr}_tar/${usr}_$n.tar --files-from=/tmp/${usr}_$n.tar.txt
  if [ $? -ne 0 ]; then echo $n?; exit; fi
  du -sch ../${usr}_tar/${usr}_$n.tar
  awk '{print "\""$0"\""}' /tmp/${usr}_$n.tar.txt | xargs rm
  if [ $? -ne 0 ]; then echo $n??; exit; fi
  date; echo ${usr} $n done
  if [ -e STOP ]; then echo stop; exit; fi
done
