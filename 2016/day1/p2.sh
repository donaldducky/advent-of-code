#!/bin/bash

# break input into newlines
# split each line into fields (ie. L10 -> L 10)
# calculate angle based on direction turned
# ensure angle is positive
# calculate direction to move
# take one step at a time and mark visited
# if we've already visited a position, exit
# calculate distance using absolute values (awk doesn't have abs so do it by hand sqrt(n^2))
perl -pe 's/, /\n/g' input.txt \
  | perl -pe 's/([LR])([0-9])/\1 \2/' \
  | awk 'BEGIN { x = 0; y = 0; d = 90; }
  #BEGIN { print "starting at", x, y, "direction", d }
  /R/ { d = d - 90 }
  /L/ { d = d + 90 }
  { d = (d + 360) % 360 }
  d == 0 { dx = 1; dy = 0 }
  d == 90 { dx = 0; dy = 1 }
  d == 180 { dx = -1; dy = 0 }
  d == 270 { dx = 0; dy = -1 }

  {
    for (i = 0; i < $2; i++)
      {
        x += dx;
        y += dy;
        key = sprintf("%d,%d", x, y);
        #print "visiting", key;
        if (key in visited) {
          #print "FOUND", key;
          exit
        }
        visited[key] = 1
      }
    }

  #{ printf("%s %d d=%d @ %d,%d\n", $1, $2, d, x, y, dx, dy) }
END { print "Part 2:", sqrt(x^2) + sqrt(y^2) }'
