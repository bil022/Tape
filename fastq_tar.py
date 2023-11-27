#!/usr/bin/env python3

import sys
import re

# df -k .
df=0
valid = re.compile(r"\s\d+\s+\d+\s+(\d+)\s")
for ln in sys.stdin:
  match = valid.search(ln)
  if match is not None:
    df=match.group(1)

print(df)
  
'''
exit

$ df -k .
Filesystem   1024-blocks      Used Available Capacity iused     ifree %iused  Mounted on
/dev/disk3s5   482797652 410406464  53947344    89% 6021043 539473440    1%   /System/Volumes/Data

bli@ren-macmini-m1 tape_F % df -k .
Filesystem                 1024-blocks        Used   Available Capacity     iused      ifree %iused  Mounted on
//admin@169.254.8.135/Data 93170426840 70055388176 23115038664    76% 18997639413 4294967295   82%   /Volumes/Data

[/share/CACHEDEV2_DATA/Data/tape_G] # df -k .
Filesystem           1K-blocks      Used Available Use% Mounted on
/dev/mapper/cachedev2
                     93170967512 70055388176 23115038664  75% /share/CACHEDEV2_DATA

https://www.guru99.com/python-regular-expressions-complete-tutorial.html#:~:text=match()%20function%20of%20re,it%20returns%20the%20match%20object.
'''
