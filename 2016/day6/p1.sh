#!/bin/bash

for i in {1..8}; do
  cat input.txt | cut -c $i-$i | sort | uniq -c | sort -n | awk '{print $2}' | tail -n1
done | awk '{printf("%s", $1)}'
