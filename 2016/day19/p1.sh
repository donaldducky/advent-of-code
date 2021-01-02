#!/bin/bash

fn="sample.txt"
fn="input.txt"

<"$fn" awk '
{ n=$1 }
END {
  min = 1
  r = 0
  while (n > 1) {
    r++
    if (n % 2 == 1) {
      min += 2^r
    }

    n = int(n/2)
  }

  print "Part 1:", min
}
'
