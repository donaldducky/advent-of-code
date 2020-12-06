#!/bin/bash

# initialize coordinates for keypad
# split on empty string to iterate over each character
# move to the next number, if within bounds
# after processing a line, append the number to the code
awk 'BEGIN { code=""; x=-2; y=0 }
  {
    nums[0,2] = 1;
    nums[-1,1] = 2;
    nums[0,1] = 3;
    nums[1,1] = 4;
    nums[-2,0] = 5;
    nums[-1,0] = 6;
    nums[0,0] = 7;
    nums[1,0] = 8;
    nums[2,0] = 9;
    nums[-1,-1] = "A";
    nums[0,-1] = "B";
    nums[1,-1] = "C";
    nums[0,-2] = "D";
  }
  {
    split($0, c, "")
    for (i=0; i<length(c); i++) {
      dx = 0;
      dy = 0;
      if (c[i] == "U") dy = 1
      if (c[i] == "D") dy = -1
      if (c[i] == "L") dx = -1
      if (c[i] == "R") dx = 1
      if (sqrt((x+dx)^2) + sqrt((y+dy)^2) <= 2) {
        x += dx;
        y += dy;
      }
      #print c[i], nums[x,y]
    }
    #print x, y, nums[x,y]
    code = code nums[x,y]
  }
  END { print code }
' input.txt
