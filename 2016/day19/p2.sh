#!/bin/bash

fn="sample.txt"
fn="input.txt"

<"$fn" awk '
{ n=$1 }
END {
  for (i = 1; i <= n; i++) {
    l[i] = i
    nxt[i] = i + 1
    if (i == n) {
      nxt[i] = 1
    }
  }

  i = 1
  mid = int(n / 2)
  while (n > 1) {
    # remove mid elem
    nxt[mid] = nxt[nxt[mid]]

    if (n % 2 == 1) {
      mid = nxt[mid]
    }

    i = nxt[i]
    n--
  }

  print "Part 2:", l[i]
}
'
