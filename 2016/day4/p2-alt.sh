#!/bin/bash

{
  tr 'a-z' 'b-za-a' < input.txt
  tr 'a-z' 'c-za-b' < input.txt
  tr 'a-z' 'd-za-c' < input.txt
  tr 'a-z' 'e-za-d' < input.txt
  tr 'a-z' 'f-za-e' < input.txt
  tr 'a-z' 'g-za-f' < input.txt
  tr 'a-z' 'h-za-g' < input.txt
  tr 'a-z' 'i-za-h' < input.txt
  tr 'a-z' 'j-za-i' < input.txt
  tr 'a-z' 'k-za-j' < input.txt
  tr 'a-z' 'l-za-k' < input.txt
  tr 'a-z' 'm-za-l' < input.txt
  tr 'a-z' 'n-za-m' < input.txt
  tr 'a-z' 'o-za-n' < input.txt
  tr 'a-z' 'p-za-o' < input.txt
  tr 'a-z' 'q-za-p' < input.txt
  tr 'a-z' 's-za-q' < input.txt
  tr 'a-z' 't-za-s' < input.txt
  tr 'a-z' 'u-za-t' < input.txt
  tr 'a-z' 'v-za-u' < input.txt
  tr 'a-z' 'w-za-v' < input.txt
  tr 'a-z' 'x-za-w' < input.txt
  tr 'a-z' 'y-za-x' < input.txt
  tr 'a-z' 'z-za-y' < input.txt
} | rg north | perl -pe 's/[^\d]+(\d+).*/\1/'
