#!/bin/bash

fn="sample.txt"
fn="input.txt"

<"$fn" awk '
{print}
{
  num_positions[NR] = $4
  current = $(NF)
  gsub(/\.$/, "", current)
  current_positions[NR] = current
}

END {
  num_positions[NR+1] = 11
  current_positions[NR+1] = 0

  t = 0
  found = 0
  while (!found) {
    for (i = 1; i <= NR + 1; i++) {
      found = 1
      if ((current_positions[i]+ i + t) % num_positions[i]) {
        found = 0
        break;
      }
    }

    if (!found) {
      t++
    }
  }

  print t
}
'
