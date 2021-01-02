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
    #print r
    #print row
    if (!(row in rows)) {
      next_row = ""
      for (c = 0; c < w; c++) {
        left = c - 1 < 0 ? "." : substr(row, c, 1)
        center = substr(row, c+1, 1)
        right = c + 1 > w - 1 ? "." : substr(row, c+2, 1)
        lookup = left center right
        tile = lookup in traps ? "^" : "."
        next_row = next_row tile
      }
      rows[row] = next_row
    }
    if (!(row in counts)) {
      row_copy = row
      counts[row] = gsub(/\./, "", row_copy)
    }

    safe += counts[row]
    prev_row = row
    row = rows[row]
  }

  print "Part 2:", safe
}
'
