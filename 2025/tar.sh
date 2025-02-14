#!/bin/bash

user=`pwd | xargs basename`
echo $user
date

find . -type f -print0 | awk -v RS='\0' '
BEGIN {
    total_size = 0
    tar_count = 1
    filelist = "/tmp/'$user'_01.tar.txt"
}
{
    # Use system command to get file size
    cmd = "stat --printf=\"%s\" \"" $0 "\""
    cmd | getline file_size
    close(cmd)
    if (total_size + file_size > 1000 * 1024 * 1024 * 1024) {
        printf("tar -cf '$user'_%02d.tar --files-from=%s\n", tar_count, filelist)
        tar_count++
        total_size = 0
        filelist = "/tmp/'$user'_" tar_count ".tar.txt"
    }
    print $0 > filelist
    total_size += file_size
}
END {
    if (total_size > 0) {
        printf("tar -cf '$user'_%02d.tar --files-from=%s\n", tar_count, filelist)
    }
}'

date
echo $user done
