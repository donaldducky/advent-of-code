#!/bin/bash

cat input.txt \
  | perl -pe 's/[^a-z0-9\n]//g' \
  | perl -pe 's/([a-z]+)(\d+)([a-z]+)/\1 \2 \3/' \
  | awk '
  BEGIN { sum = 0 }
  { print $0 }
  { valid = 1 }
  { split($1, letters, "") }
  # assuming checksum is in order
  { split($3, checksum, "") }
  { for (i in letters) counts[letters[i]]++ }
  { for (c in counts) printf("%s:%d ", c, counts[c]); print "" }
  {
    # sufficiently high number
    max = 9999999
    # strings are 1 indexed
    for (i = 1; i <= length(checksum); i++) {
      ltr = checksum[i]
      c = counts[ltr]

      # filter missing
      if (c == 0) {
        print "✗ missing", ltr
        valid = 0
        break
      }
      #printf("%s:%d\n", ltr, c)

      # filter too high count
      if (c > max) {
        print "✗ count too high", ltr
        valid = 0
        break
      }
      max = c
      #print "setting max to", c
      #print "deleting", ltr
      delete counts[ltr]
      minLetter = ltr
    }
    printf("\n")
  }
  # check remaining to ensure letter order
  valid == 1 {
    print "remaining with max", max, "minLetter", minLetter
    for (i in counts) {
      ltr = i
      c = counts[i]
      if (c > max) {
        print "✗ count too high", ltr
        valid = 0
        break
      }
      if (c == max && ltr < minLetter) {
        print "✗ found lower letter", ltr
        valid = 0
        break
      }
    }
    print ""
  }
  { delete counts; max = 0 }
  valid == 1 { sum += $2 }
  END { print sum }
  #END { print ("a" < "b") ? "a is lower" : "b is lower" }
';
