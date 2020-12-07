#!/bin/bash

<input.txt tr 'FLBR' '0011' | sort -nr | head -1 | awk '{print "ibase=2;"  $1}' | bc
