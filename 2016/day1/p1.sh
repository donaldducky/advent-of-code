#!/bin/bash

perl -pe 's/, /\n/g' input.txt \
  | perl -pe 's/([LR])([0-9])/\1 \2/' \
  | awk 'BEGIN { x = 0; y = 0; d = 90 }
  #BEGIN { print "starting at", x, y, "direction", d }
  /R/ { d = d - 90 }
  /L/ { d = d + 90 }
  { d = (d + 360) % 360 }
  d == 0 { x = x + $2 }
  d == 90 { y = y + $2 }
  d == 180 { x = x - $2 }
  d == 270 { y = y - $2 }
  #{ printf("%s %d d=%d @ %d,%d\n", $1, $2, d, x, y, dx, dy) }
END { print "Part 1:", sqrt(x^2) + sqrt(y^2) }'
