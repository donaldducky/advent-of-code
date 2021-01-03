#!/bin/bash

fn="sample.txt" min=0 max=9
fn="input.txt" min=0 max=4294967295

<"$fn" sort -n | awk -F"-" -v min="$min" -v max="$max" '
{print NR, $0}
NR == 1 { lo=$1; hi=$2 }
NR > 1 {
  if (hi + 1 < $1) {
    exit
  }

  lo = $1 < lo ? $1 : lo
  hi = $2 > hi ? $2 : hi
}

END {
  print "Part 1:", hi + 1
}
'
