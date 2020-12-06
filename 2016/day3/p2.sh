#!/bin/bash

# transpose columns
# chunk columns into rows with 3 columns each
# sort columns, numerically
# filter valid triangles
# count
<input.txt \
  rs -T \
  | awk '{ for (i = 1; i <= NF; i += 3) { printf("%d %d %d\n", $i, $(i+1), $(i+2)) } }' \
  | perl -lane 'print "@{[sort {$a <=> $b} @F]}"' \
  | awk '$1 + $2 > $3' \
  | wc -l
