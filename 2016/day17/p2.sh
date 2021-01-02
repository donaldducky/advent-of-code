#!/bin/bash

fn="sample.txt"
fn="sample4.txt"
fn="sample3.txt"
fn="sample2.txt"
fn="input.txt"

# awk solution's md5 is too slow since it pipes into md5sum
# string length may also be a problem
<"$fn" cat | perl -e '
use Digest::MD5 qw(md5_hex);

my $in = <STDIN>;
chomp $in;
print "$in\n";

my $WIDTH = 4;
my $HEIGHT = 4;
my ($sx, $sy) = (0, 0);
my ($gx, $gy) = (3, 3);
my %NEIGHBOURS = (
  1 => ["U", 0, -1],
  2 => ["D", 0, 1],
  3 => ["L", -1, 0],
  4 => ["R", 1, 0],
);

my @open = ();
push(@open, (join ":", "", $sx, $sy));

my $max = 0;
while (scalar @open) {
  my @open2 = ();
  foreach (@open) {
    my ($path, $x, $y) = split /:/, $_;
    my $h = md5_hex("$in$path");
    #print "$h $path ($x, $y)\n";

    for (my $i=1; $i <= 4; $i++) {
      my $x1 = $x + $NEIGHBOURS{$i}[1];
      my $y1 = $y + $NEIGHBOURS{$i}[2];

      # out of bounds
      if ($x1 < 0 || $x1 > $WIDTH - 1 || $y1 < 0 || $y1 > $HEIGHT - 1) {
        next;
      }

      my $c = substr $h, $i - 1, 1;
      if ($c !~ /[b-f]/) {
        next;
      }

      #print "$i $NEIGHBOURS{$i}[0] ($x1, $y1) $c\n";
      if ($x1 == $gx && $y1 == $gy) {
        my $len = length($path) + 1;
        if ($len > $max) {
          $max = $len;
        }
      } else {
        push(@open2, (join ":", "$path$NEIGHBOURS{$i}[0]", $x1, $y1));
      }
    }
  }
  @open = @open2;
}

print "Part 2: $max\n";
'
