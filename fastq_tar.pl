#!/usr/bin/perl

die "usage: $ARGV[0]" unless @ARGV;
$dst=$ARGV[0];
$dst=~s/\/$//;
die "dst? $dst" unless ( -d "$dst" );

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

foreach $key (keys %hash) {
  print("echo $key $SIZE{$key} K\n");
  print("tar -cvf $dst/$key.tar -C $dir @{$hash{$key}}\n");
}
