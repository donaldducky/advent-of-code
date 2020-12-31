#!/bin/bash

fn="sample.txt"
fn="input.txt"

#<"$fn" cat | perl p1.pl
<"$fn" cat | perl -e '
use Digest::MD5 qw(md5_hex);

my $in = <STDIN>;
chomp $in;
print "$in\n";

my $i = 0;
my %track = ();
my @hashes = ();

# TODO possibility we find a quintuplet for a hex digit that results
# in indices less than the ones found up to 64, we should probably
# check for that case (ie. 64th element is less than the minimum triplet)
while (scalar @hashes < 64) {
  $h = md5_hex("$in$i");

  if ($h =~ /((\w)\2{4})/) {
    #print "$i (5) $h $1 $2\n";
    while ($v = shift(@{$track{"$2"}})) {
      if ($i - $v <= 1000) {
        #print "Found hash at index $v\n";
        push(@hashes, $v);
      }
    }
  }

  if ($h =~ /((\w)\2{2})/) {
    if (exists($track{"$2"})) {
      push(@{$track{"$2"}}, $i)
    } else {
      $track{"$2"} = [$i]
    }
    #print "$i (3) $h $1 $2\n";
  }

  $i++;
}

@hashes = sort { $a <=> $b } @hashes;

print "Part 1: $hashes[63]\n";
#print "Part 1: @hashes\n";
'
