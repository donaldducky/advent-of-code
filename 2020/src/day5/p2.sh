#!/bin/bash

<input.txt tr 'FLBR' '0011' | sort -n | awk '{print "ibase=2;"  $1}' | bc | awk '$1 - prev == 2 { exit } {prev = $1} END { print ($1-1) }'
