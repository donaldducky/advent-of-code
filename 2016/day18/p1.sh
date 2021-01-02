#!/bin/bash

fn="sample.txt" rows=3
fn="sample2.txt" rows=10
fn="input.txt" rows=40

<"$fn" awk -v rows="$rows" '
END {
  safe=0

  w = length($1)
  h = rows

  print w "x" h

  traps["^^."] = 1
  traps[".^^"] = 1
  traps["^.."] = 1
  traps["..^"] = 1

  for (r = 0; r < h; r++) {
    for (c = 0; c < w; c++) {
      # build first
      if (r == 0) {
        grid[r,c] = substr($1, c+1, 1)
      } else {
        left = c - 1 < 0 ? "." : grid[r-1,c-1]
        center = grid[r-1,c]
        right = c + 1 > w - 1 ? "." : grid[r-1,c+1]

        grid[r,c] = (left center right) in traps ? "^" : "."
      }

      if (grid[r,c] == ".") {
        safe++
      }
      printf("%s", grid[r,c])
    }
    print ""
  }

  print "Part 1:", safe
}
'
