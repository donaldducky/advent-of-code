#!/bin/bash

<input.txt \
  perl -pe 's/(\w)(\w)/\1 \2 /g' \
  | awk '
  !/^$/ {
    split($0, arr)
    for (c in arr) seen[arr[c]]++
  }
  /^$/ {
    yes += length(seen)
    delete seen
  }
  END {
    yes += length(seen)
    print "Part 1:", yes
  }
  '
