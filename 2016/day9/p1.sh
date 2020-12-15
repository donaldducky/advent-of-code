#!/bin/bash

#cat input.txt

in="ADVENT"
in="A(1x5)BC"
in="(3x3)XYZ"
in="A(2x2)BCD(2x2)EFG"
in="(6x1)(1x3)A"
in="X(8x2)(3x3)ABCY"
in=$(cat "input.txt")

echo "$in" | awk '
{
  l=length($1)
  d=""

  do {
      where = match($1, /\([0-9]+x[0-9]+\)/)
      if (where != 0) {
        #print "match", RSTART, RLENGTH
        d=d substr($1, 1, RSTART - 1)
        split(substr($1, RSTART+1, RLENGTH - 2), out, "x")
        #print "str=" out[1], "reps=" out[2]
        repeat=substr($1, RSTART + RLENGTH, out[1])
        for (i = 0; i < out[2]; i++) {
          d=d repeat
        }
        #print "l=" l, "RL=" RLENGTH, "RS=" RSTART, "n=" l - RLENGTH - RSTART + 1, substr($1, RLENGTH + RSTART, l - RLENGTH - RSTART + 1)
        #print $1, RLENGTH + RSTART
        $1 = substr($1, RLENGTH + RSTART + out[1], l - RLENGTH - RSTART)
      } else {
        d=d $1
        $1 = ""
      }
    l = length($1)
  } while (l > 0)

  #print d
  print length(d)
}'
