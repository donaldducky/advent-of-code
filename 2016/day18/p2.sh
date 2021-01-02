#!/bin/bash

fn="sample.txt" rows=3
fn="sample2.txt" rows=10
fn="input.txt" rows=400000

<"$fn" awk -v h="$rows" '
END {
  safe=0

  w = length($1)
  #print w "x" h

  traps["^^."] = 1
  traps[".^^"] = 1
  traps["^.."] = 1
  traps["..^"] = 1

  row = $1
  for (r = 0; r < h; r++) {
    next_row = ""
    for (c = 0; c < w; c++) {
      lookup = substr("." row ".", c + 1, 3)
      tile = lookup in traps ? "^" : "."
      next_row = next_row tile
    }
    rows[row] = next_row

    row_copy = row
    safe += gsub(/\./, "", row_copy)

    #print row, "("r")", counts[row]

    row = next_row
  }

  print "Part 2:", safe
}
'
