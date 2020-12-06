#!/bin/bash

# sort column, numerically
# filter valid triangles
# count
<input.txt \
  perl -lane 'print "@{[sort {$a <=> $b} @F]}"' \
  | awk '$1 + $2 > $3' \
  | wc -l
