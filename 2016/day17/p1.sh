#!/bin/bash

fn="sample.txt"
fn="sample2.txt"
fn="sample4.txt"
fn="sample3.txt"
fn="input.txt"

<"$fn" awk '
function md5(s) {
  cmd="bash -c \"echo -n " s "\" | md5sum | awk \"{print \\$1}\""
  cmd | getline h
  close(cmd)
  return h
}

function is_open(c) {
  return c ~ /[b-f]/
}

BEGIN {
  sx = sy = 0
  gx = gy = 3
  width = height = 3
  UP=1
  DOWN=2
  LEFT=3
  RIGHT=4
  NX[UP] = 0; NY[UP] = -1
  NX[DOWN] = 0; NY[DOWN] = 1
  NX[LEFT] = -1; NY[LEFT] = 0
  NX[RIGHT] = 1; NY[RIGHT] = 0
  NEIGHBOURS[UP]="U"
  NEIGHBOURS[DOWN]="D"
  NEIGHBOURS[LEFT]="L"
  NEIGHBOURS[RIGHT]="R"
}

{print}

{ passcode=$1 }

END {
  open[0] = "" SUBSEP sx SUBSEP sy
  found = 0

  while (length(open) && !found) {
    # copy to new array
    delete nodes
    for (o in open) {
      nodes[o] = open[o]
    }
    delete open

    n = 0
    for (ni in nodes) {
      if (found) {
        break
      }
      split(nodes[ni], node, SUBSEP)

      path = node[1]
      h = md5(passcode path)
      x = node[2]
      y = node[3]
      print "hash="passcode path, h, "(" x ", " y ")", "path="path

      for (d in NEIGHBOURS) {
        x1 = x + NX[d]
        y1 = y + NY[d]

        # out of bounds
        if (x1 < 0 || x1 > width || y1 < 0 || y1 > height) {
          continue
        }

        c = substr(h, d, 1)

        if (!is_open(c)) {
          continue
        }

        if (x1 == gx && y1 == gy) {
          found = 1
          path = path NEIGHBOURS[d]
          print "found goal", path
        } else {
          print NEIGHBOURS[d], "(" x1 "," y1 ")", c, "open?", is_open(c)
          open[n] = path NEIGHBOURS[d] SUBSEP x1 SUBSEP y1
          n++
        }
      }
    }
  }

  if (found) {
    print "Part 1:", path
  } else {
    print "Failed to find a path"
  }
}
'

#<"$fn" cat | perl -e '
#use Digest::MD5 qw(md5_hex);
#
#my $in = <STDIN>;
#chomp $in;
#print "$in\n";
#
#$h = md5_hex("$in");
#
#print "$h"
#'
