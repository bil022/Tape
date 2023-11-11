#!/usr/bin/perl

die "usage: $ARGV[0]" unless @ARGV;
$dst=$ARGV[0];
$dst=~s/\/$//;
die "dst? $dst" unless ( -d "$dst" );

while (<DATA>) {
  if (/^(\S+):/) {
    $SRC{$tag}=$script; undef $script;
    $tag=$1; next;
  }
  $script.=$_;
}
$SRC{$tag}=$script if $tag;

while (<STDIN>) {
  chomp();
  s/\/+/\//g;
  ($sizeK, $path)=split(/\t/);
  die "size?" unless $sizeK=~/^[0-9]+$/;
  die "$path?" unless $path=~/\S\/\S/;
  warn "$path??" unless ( -e "$path" );
  ($dir, $base)=split(/\//, $path);
  $key="misc";
  if ($base=~/^(\d+)_(\d\d)/) { 
    ($year, $mm)=($1, $2);
    $key="${year}_$mm";
  }
  $SIZE{$key}+=$sizeK;
  push(@{$hash{$key}}, '"'.$path.'"');
}

print "$SRC{HEAD}" if exists $SRC{HEAD};
foreach $key (keys %hash) {
  print("echo $key $SIZE{$key} K\n");
  print("tar -cvf $dst/$key.tar -C $dir @{$hash{$key}}\n");
  print("check_ret $dst/$key.tar \$*\n");
}
print "$SRC{TAIL}" if exists $SRC{TAIL};

__END__
HEAD:
#!/bin/bash
  
df=`df -g . | awk '{n=$4}END{print n}'`
if [ $df -eq 0 ]; then echo "No space"; exit; fi

pid=${0%%sh}pid
if [ -f $pid ]; then echo "Found $pid"; exit; fi
echo $$ > $pid

panic=${0%%sh}panic
if [ -e $panic ]; then echo "Fanic $panic"; exit; fi

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
