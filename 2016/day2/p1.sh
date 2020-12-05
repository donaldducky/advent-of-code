#!/bin/bash

awk 'BEGIN { code=""; x=0; y=0 }
  {
    nums[-1,1] = 1;
    nums[0,1] = 2;
    nums[1,1] = 3;
    nums[-1,0] = 4;
    nums[0,0] = 5;
    nums[1,0] = 6;
    nums[-1,-1] = 7;
    nums[0,-1] = 8;
    nums[1,-1] = 9;
  }
  {
    split($0, c, "")
    for (i=0; i<length(c); i++) {
      if (c[i] == "U") y++
      if (c[i] == "D") y--
      if (c[i] == "L") x--
      if (c[i] == "R") x++
      if (x > 0) x = 1
      if (x < 0) x = -1
      if (y > 0) y = 1
      if (y < 0) y = -1
      #print c[i], nums[x,y]
    }
    #print x, y, nums[x,y]
    code = code nums[x,y]
  }
  END { print code }
' input.txt
