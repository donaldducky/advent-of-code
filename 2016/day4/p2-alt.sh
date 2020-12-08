#!/bin/bash

in=$(cat input.txt)
for i in {1..26} do
{
  echo "$in"
  in=$(echo "$in" | tr 'a-z' 'b-za-a')
} | rg north | perl -pe 's/[^\d]+(\d+).*/\1/'
