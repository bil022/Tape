#!/bin/bash

usr=naoki-ps-renlab
#gtar -cf naoki-ps-renlab_12.tar -T /tmp/naoki-ps-renlab_12.tar.txt
for n in `seq -f "%02g" 1 1`; do
  date; echo begin ${usr} $n
  gtar -cf ../${usr}_tar/${usr}_$n.tar --files-from=/tmp/${usr}_$n.tar.txt
  if [ $? -ne 0 ]; then echo $n?; exit; fi
  du -sch ../${usr}_tar/${usr}_$n.tar
  awk '{print "\""$0"\""}' /tmp/${usr}_$n.tar.txt | xargs rm
  if [ $? -ne 0 ]; then echo $n??; exit; fi
  date; echo ${usr} $n done
  if [ -e STOP ]; then echo stop; exit; fi
done
