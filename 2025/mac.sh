#!/bin/bash

# Set the maximum tar file size in bytes (100GB)
MAX_SIZE=$((1000 * 1024 * 1024 * 1024))

# Get the current directory name as the base name
user=$(basename "$PWD")

# Initialize variables
total_size=0
tar_count=1
filelist="/tmp/${user}_01.tar.txt"

# Print start message
echo "Starting tar splitting for directory: $PWD"
date

# Find all files and process them
find . -type f -print0 | while IFS= read -r -d '' file; do
    # Get file size (macOS version of stat)
    file_size=$(stat -f "%z" "$file")

    # Check if adding this file would exceed the max tar size
    if (( total_size + file_size > MAX_SIZE )); then
        # Create the tar file and reset counters
        echo "Creating tar: ${user}_$(printf "%02d" "$tar_count").tar"
        tar -cf "${user}_$(printf "%02d" "$tar_count").tar" -T "$filelist"
        tar_count=$((tar_count + 1))
        total_size=0
        filelist="/tmp/${user}_$(printf "%02d" "$tar_count").tar.txt"
    fi

    # Add the file to the list
    echo "$file" >> "$filelist"
    total_size=$((total_size + file_size))
done

# Final tar if there are remaining files
if (( total_size > 0 )); then
    echo "Creating final tar: ${user}_$(printf "%02d" "$tar_count").tar"
    tar -cf "${user}_$(printf "%02d" "$tar_count").tar" -T "$filelist"
fi

# Print completion message
date
echo "Tar splitting completed for $user"
