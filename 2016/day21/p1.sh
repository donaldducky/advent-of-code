#!/bin/bash

fn="sample.txt" input="abcde"
fn="input.txt" input="abcdefgh"

<"$fn" awk -v input="$input" '
function p() {
  for (i = 1; i <= n; i++) printf("%s", letters[i])
  print ""
}

BEGIN {
  #print input
  split(input, letters, "")
  n = length(input)
}

#{ print }

/swap position/ {
  #print $3, $6
  h = letters[$3+1]
  letters[$3+1] = letters[$6+1]
  letters[$6+1] = h
}

/swap letter/ {
  #print $3, $6
  for (i = 1; i <= n; i++) {
    if (letters[i] == $3) letters[i] = $6
    else if (letters[i] == $6) letters[i] = $3
  }
}

/reverse positions/ {
  j = $5 + 1
  for (i = $3; i <= $5; i++) {
    #print i + 1, letters[i+1], j
    swap[j] = letters[i+1]
    j--
  }

  for (i in swap) {
    letters[i] = swap[i]
  }
  delete swap
}

/rotate left/ {
  r=$3
  s=""
  for (i = 1; i <= n; i++) {
    s=s letters[i]
  }

  while (r) {
    s = substr(s, 2, n-1) substr(s, 1, 1)
    r--
  }
  split(s, letters, "")
}

/rotate right/ {
  r=$3
  s=""
  for (i = 1; i <= n; i++) {
    s=s letters[i]
  }

  while (r) {
    s = substr(s, n, 1) substr(s, 1, n-1)
    r--
  }
  split(s, letters, "")
}

/move position/ {
  from=$3
  to=$6

  popped = letters[$3+1]
  for (i = from; i < n; i++) {
    letters[i+1] = letters[i+2]
  }
  for (i = n; i > to; i--) {
    letters[i] = letters[i - 1]
  }
  letters[to + 1] = popped
}

/rotate based/ {
  #print $7
  for (i in letters) {
    if (letters[i] == $7) {
      idx = i - 1
      break;
    }
  }
  r = idx >= 4 ? 2 + idx : 1 + idx
  #print idx, r

  s=""
  for (i = 1; i <= n; i++) {
    s=s letters[i]
  }
  while (r) {
    s = substr(s, n, 1) substr(s, 1, n-1)
    r--
  }
  split(s, letters, "")
}

#{ p(); print "" }

END {
  printf("Part 1: ")
  p()
}
'
