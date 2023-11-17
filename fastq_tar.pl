#!/usr/bin/perl

die "usage: $ARGV[0]" unless @ARGV;    #a destination folder is required as an input
$dst=$ARGV[0];
$dst=~s/\/$//;    #get rid of "/" at the end of the folder name if have any
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
  $key="misc";    #the target for folders not match specific pattern: Y(1-4 digitals)_MM(2 digitals)
  if ($base=~/^(\d+)_(\d\d)/) {    #if the sub-folder matches the pattern
    ($year, $mm)=($1, $2);    #get the year and month for each sub-folder
    $key="${year}_$mm";    #set the new target
  }
  $SIZE{$key}+=$sizeK;    #record the size of the target
  push(@{$hash{$key}}, '"'.$path.'"');    #record the folders for the target
}

while (<DATA>) {    #start to read content after "__END__"
  if (/^(\S+):/) {    #when reaching the point start with non-whitespace followed by ":", in this case, "HEAD:" and "TAIL:"
    $SRC{$tag}=$script; undef $script;    #record content in a hash table with the tag as key, in this case, "HEAD:" and "TAIL:"
    $tag=$1; next;    #set the tag
  }
  s/SIZE/$sumK/g;    #substitute "SIZE" with the sum of the folder size (defined in line 8)
  $script.=$_;    #add to script
}
$SRC{$tag}=$script if $tag;    # ?? update the hash table content

print "$SRC{HEAD}" if exists $SRC{HEAD};    #print out "HEAD:" in the hash table "SRC"
foreach $key (sort keys %hash) {    #go through each key in the hash table "hash" which is the target
  print("echo $key $SIZE{$key} K\n");    #print out the size of the target
  print("tar -cvf $dst/$key.tar -C $dir @{$hash{$key}}\n");    #print out the tar command that will be used to compress the folders
  print("check_ret $dst/$key.tar \$?\n");    #check if the tar command runs through without any issue (function "check_ret" is defined below) 
}
print "$SRC{TAIL}" if exists $SRC{TAIL};    #print out "TAIL:" in the hash table "SRC"

__END__
HEAD:
#!/bin/bash
  
df=`df -k . | awk '{n=$4}END{print n+1000}'`
if [ $df -lt SIZE ]; then echo "Not enough space: $df < SIZE"; exit; fi

pid=${0%%sh}pid
if [ -f $pid ]; then echo "Found $pid"; exit; fi
echo $$ > $pid

panic=${0%%sh}panic
if [ -e $panic ]; then echo "Panic $panic"; exit; fi

function check_ret {
  msg=$1; shift
  for ret in $*; do
    if [ $ret -ne 0 ]; then
      echo $msg $* > $panic
      locate mail
      if [ $? -eq 0 ]; then
        echo $msg $* | mail -s "Error in $msg" bil022@ucsd.edu
      fi
      exit
    fi
  done
}

TAIL:
rm $pid
