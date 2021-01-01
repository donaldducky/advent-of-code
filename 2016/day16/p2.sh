#!/bin/bash

fn="sample.txt"; n=20
fn="input.txt"; n=272
fn="input.txt"; n=35651584

<"$fn" awk -v n="$n" '
function rev(s) {
  r = ""
  for (i = length(b); i > 0; i--) {
    r = r substr(b, i, 1)
  }
  return r
}

function flip_bits(s) {
  b = s
  gsub(/1/, "x", b)
  gsub(/0/, "1", b)
  gsub(/x/, "0", b)

  return b
}

{ a = $1 }
END {
  print "input:", a, "len:", length(a), "length:", n, "b:", rev(flip_bits(a))
  print n
  c = 0
  l = n
  while (l % 2 == 0) {
    c++
    l /= 2
  }
  #print "l="l, "c="c

  split(a, a2, "")

  len = length(a2)
  while (len < n) {
    max = 2 * len + 1
    for (i = 1; i <= len; i++) {
      a2[max - i + 1] = a2[i] == "0" ? "1" : "0"
    }
    a2[len + 1] = "0"
    len = max
    print len
  }

  diff = len - n
  for (i = len; i > len - diff; i--) {
    delete a2[i]
  }
  len -= diff

  do {
    for (i = 1; i <= len; i +=2) {
      if (a2[i] == a2[i+1]) {
        a2[(i + 1) / 2] = "1"
      } else {
        a2[(i + 1) / 2] = "0"
      }
    }
    len /= 2
    print len
  } while (len % 2 == 0)

  printf("Part 2: ")
  for (i = 1; i <= len; i++) {
    printf("%s", a2[i])
  }
  print ""
}
'
