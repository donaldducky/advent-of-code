#!/bin/bash

<input.txt \
  perl -pe 's/(\w)(\w)/\1 \2 /g' \
  | awk '
  #BEGIN { print "start" }
  !/^$/ {
    n++
    #print
    split($0, arr)
    for (c in arr) seen[arr[c]]++
  }
  /^$/ {
    #print n, "answered";
    for (c in seen) {
      #print c, seen[c];
      if (seen[c] == n) same++
    }
    #print "empty line"
    delete seen
    n=0
  }
  END {
    #print n, "answered";
    for (c in seen) {
      #print c, seen[c];
      if (seen[c] == n) same++
    }
    print "Part 2:", same
  }
  '
