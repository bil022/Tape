all:
	./fastq_tar.sh tape 2022
test:
	@cat input.txt | ./fastq_tar.pl tape
	# cd /Volumes/Data/tape_G && find 2014 2015 -mindepth 1 -maxdepth 1 -exec du -sk '{}' \; > input.txt
