#!/bin/bash

fn="sample.txt"; n=20
fn="input.txt"; n=272

<"$fn" awk -v n="$n" '
{ a = $1 }
END {
  print "input:", a, "length:", n

  while (length(a) < n) {
    b = a
    gsub(/1/, "x", b)
    gsub(/0/, "1", b)
    gsub(/x/, "0", b)
    r = ""
    for (i = length(b); i > 0; i--) {
      r = r substr(b, i, 1)
    }
    #print "a="a, "b="b, "r="r
    a = a "0" r
    #print "extended="a
  }

  data = substr(a, 1, n)
  #print data

  do {
    checksum = ""
    for (i = 1; i <= length(data); i += 2) {
      if (substr(data, i, 1) == substr(data, i+1, 1)) {
        checksum = checksum "1"
      } else {
        checksum = checksum "0"
      }
    }

    #print checksum
    data = checksum
  } while (length(checksum) % 2 == 0)

  print "Part 1:", checksum
}
'
