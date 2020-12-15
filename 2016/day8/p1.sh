#!/bin/bash

filename="sample.txt"; w=7; h=3
filename="sample2.txt"; w=10; h=3
filename="input.txt"; w=50; h=6

cat "$filename" | perl -pe 's/rect (\d+)x(\d+)/rect \1 \2/g' \
  | perl -pe 's/rotate (column|row) [xy]=(\d+) by (\d+)/\1 \2 \3/' \
  | awk -v w=$w -v h=$h '

function print_grid(grid, w, h) {
  #print "__________________________________________________"
  #for (x = 0; x < w; x++) {
  #  printf("%d", x % 10)
  #}
  #printf("\n")
  #print "--------------------------------------------------"
  for (y = 0; y < h; y++) {
    for (x = 0; x < w; x++) {
      printf("%s", grid[x,y])
    }
    printf("\n")
  }
}

function rotate_right(grid, w, col, n, _cells, _str) {
  y=col

  #print "rr", col, "by", n, "w=" w

  for (x = 0; x < w; x++) {
    _str=_str "" grid[x,y]
    #print x, y, _str, length(_str)
  }
  split(_str, _cells, "")

  for (x = 0; x < w; x++) {
    x2 = (x + n) % w

    # 1 indexed
    grid[x2,y] = _cells[x + 1]
    #print _cells[x+1], x, x2, y, grid[x2,y]
  }
}

function rotate_down(grid, h, row, n, _cells, _str) {
  x=row

  #print "rd", row, "by", n, "h=" h

  for (y = 0; y < h; y++) {
    _str=_str "" grid[x,y]
    #print x, y, _str, length(_str)
  }
  split(_str, _cells, "")

  for (y = 0; y < h; y++) {
    y2 = (y + n) % h

    # 1 indexed
    grid[x,y2] = _cells[y + 1]
    #print _cells[y+1], y, y2, x, grid[x,y2]
  }
}

BEGIN {
  for (y = 0; y < h; y++) {
    for (x = 0; x < w; x++) {
      grid[x,y] = " "
    }
  }
}

#{ print $0; print_grid(grid, w, h) }

$1 == "rect" {
  for (y = 0; y < $3; y++) {
    for (x = 0; x < $2; x++) {
      grid[x,y] = "@"
    }
  }
}

$1 == "row" {
  rotate_right(grid, w, $2, $3)
}

$1 == "column" {
  rotate_down(grid, h, $2, $3)
}

END {
  c=0
  for (y = 0; y < h; y++) {
    for (x = 0; x < w; x++) {
      if (grid[x,y] == "@") {
        c++
      }
    }
  }
  print "Part 1:", c
}
'
