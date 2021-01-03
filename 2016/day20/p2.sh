#!/bin/bash

fn="sample.txt" min=0 max=9
fn="input.txt" min=0 max=4294967295

<"$fn" sort -n | awk -F"-" -v min="$min" -v max="$max" '
BEGIN { i=0; found=0 }

{print NR, $0}
!found { lo=$1; hi=$2; found=1 }
found {
  if (hi + 1 < $1) {
    los[i] = lo
    his[i] = hi
    i++
    lo = $1
    hi = $2
  } else {
    lo = $1 < lo ? $1 : lo
    hi = $2 > hi ? $2 : hi
  }
}

END {
  los[i] = lo
  his[i] = hi
  i++

  sum=0
  for (x = 0; x < i; x++) {
    if (x == 0) {
      sum += los[x] - min
    } else {
      sum += los[x] - his[x-1] - 1
    }

    print "Range #" x+1, "lo="los[x], "hi="his[x], "sum="sum

    if (x == i - 1) {
      sum += max - his[x]
    }
  }
  print "Part 2:", sum
}
'
