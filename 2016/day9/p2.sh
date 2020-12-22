#!/bin/bash

#cat input.txt

in="X(8x2)(3x3)ABCY"
in="(27x12)(20x12)(13x14)(7x10)(1x12)A"
in="(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN"
in=$(cat "input.txt")

#echo "$in" | awk -f p2.awk
# recursion in awk is tricky
# since all variables are effectively global, recursive functions are hard to
# write due to:
# - variables getting clobbered; and
# - no return values
echo "$in" | awk '
{
  d = 0
  s[0] = $1
  mx[0] = 1
  size=0

  do {
    where = match(s[d], /\([0-9]+x[0-9]+\)/)
    if (where != 0) {
      if (RSTART > 1) {
        size += length(substr(s[d], 1, RSTART - 1)) * mx[d]
      }
      m = substr(s[d], RSTART + 1, RLENGTH - 2)
      split(m, out, "x")
      r = substr(s[d], RLENGTH + RSTART, out[1])
      save[d] = substr(s[d], RSTART + RLENGTH + out[1], length(s[d]))
      d++
      s[d] = r
      mx[d] = out[2] * mx[d-1]
    } else {
      size += length(s[d]) * mx[d]
      s[d] = ""
      d--
      s[d] = save[d]
    }
  } while (length(s[0]))

  print "Part 2:", size
}'
