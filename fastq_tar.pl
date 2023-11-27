#!/usr/bin/perl
###############################
# After executing this script successfully, a .sh file will be generated and used to submit the job to compress folders and put them on tape.
# Example input format: input.txt
# Example output: output.sh
###############################

die "usage: $ARGV[0]" unless @ARGV;    #a destination folder is required as an input
$dst=$ARGV[0];
$dst=~s/\/+$//;    #get rid of "/" at the end of the folder name if have any
die "dst? $dst" unless ( -d "$dst" );    #the destination must exist otherwise the script will stop

$sumK=0;    #the sum of the folder size
while (<STDIN>) {
  chomp();
  s/\/+/\//g;    #substitute multiple "/"s with one if any
  ($sizeK, $path)=split(/\t/); $sumK+=$sizeK;    #get the size and path for each folder separated by tab and add the size to the sum
  die "size?" unless $sizeK=~/^[0-9]+$/;    #size can only contain numerical otherwise the script will stops
  die "$path?" unless $path=~/\S\/\S/;    #the path can only contain non-whitespace and "/" otherwise the script will stop
  warn "$path??" unless ( -e "$path" );    #if the path does not exist a warning will be sent
  ($dir, $base)=split(/\//, $path);    #get folder and sub-folder from path separated by "/"
  $key="${dir}_misc";    #the target for folders not match specific pattern: Y(1-4 digitals)_MM(2 digitals)
  if ($base=~/^(\d+)_(\d\d)/) {    #if the sub-folder matches the pattern
    ($year, $mm)=($1, $2);    #get the year and month for each sub-folder
    $key="${year}_$mm";    #set the new target
  }
  $SIZE{$key}+=$sizeK;    #record the size of the target
  $DIR{$key}=$dir;
  push(@{$hash{$key}}, '"'.$base.'"');    #record the folders for the target
}

while (<DATA>) {    #start to read content after "__END__"
  if (/^(\S+):/) {    #when reaching the point start with non-whitespace followed by ":", in this case, "HEAD:" and "TAIL:"
    $SRC{$tag}=$script; undef $script;    #record content in a hash table with the tag as key, in this case, "HEAD:" and "TAIL:"; clean up "script"
    $tag=$1; next;    #set the tag
  }
  s/{SIZE}/$sumK/g;    #substitute "SIZE" with the sum of the folder size (defined in line 8)
  $script.=$_;    #add to script
}
$SRC{$tag}=$script if $tag;    #update the hash table content for the last tag, in this case, "TAIL:"

print "$SRC{HEAD}" if exists $SRC{HEAD};    #print out "HEAD:" in the hash table "SRC"
foreach $key (sort keys %hash) {    #go through each key in the hash table "hash" which is the target
  print("echo $key $SIZE{$key} K\n");    #print out the size of the target
  print("tar -cvf $dst/$key.tar -C $DIR{$key} @{$hash{$key}}\n");    #print out the tar command that will be used to compress the folders
  print("check_ret $dst/$key.tar \$?\n");    #check if the tar command runs through without any issue (function "check_ret" is defined below) 
}
print "$SRC{TAIL}" if exists $SRC{TAIL};    #print out "TAIL:" in the hash table "SRC"

__END__
HEAD:
#!/bin/bash
  
py=${0%%sh}py
df=`df -k . | $py | awk '{print $1+1000}'`    #check the space left on the hard drive in K, and add 1000 extra for safety
if [ $df -lt {SIZE} ]; then echo "Not enough space: $df < {SIZE}"; exit; fi    #quit if the left hard drive space is less than the size needed for the target

pid=${0%%sh}pid    #get the job ID
if [ -f $pid ]; then echo "Found $pid"; exit; fi    #stop attempting to resubmit the job if the job ID already exists which means it's running
echo $$ > $pid    #print out the job ID

panic=${0%%sh}panic    #check if a panic file exists
if [ -e $panic ]; then echo "Panic $panic"; exit; fi    #stop attempting to submit the job if the corresponding panic file exists which means an error exists

function check_ret {    #defined function for error check returned from tar command
  msg=$1; shift    #record target file to "msg" and move to the next parameter which might be the error if any
  for ret in $*; do    #check each pipe option, in this case, there is only ONE
    if [ $ret -ne 0 ]; then    #if there is an error
      echo $msg $* > $panic    #put the target file and error info into a panic file
      locate mail    #check if mail service exists
      if [ $? -eq 0 ]; then    #if the mail service exists
        echo $msg $* | mail -s "Error in $msg" bil022@ucsd.edu    #mail the panic file to the given email
      fi
      exit    #any error will stop the script from running any further
    fi
  done
}    #function end

TAIL:
rm $pid    #clean up the job ID if runs successfully
