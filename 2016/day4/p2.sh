#!/bin/bash

paste <(
  cat input.txt \
    | perl -pe 's/[^a-z0-9\n]//g' \
    | perl -pe 's/([a-z]+)(\d+)([a-z]+)/\1 \2 \3/'
  ) <(cat input.txt | perl -pe 's/-\d+.*$//') \
  | awk '
  BEGIN { sum = 0 }
  #{ print $0 }
  { valid = 1 }
  { split($1, letters, "") }
  # assuming checksum is in order
  { split($3, checksum, "") }
  { for (i in letters) counts[letters[i]]++ }
  #{ for (c in counts) printf("%s:%d ", c, counts[c]); print "" }
  {
    # sufficiently high number
    max = 9999999
    # strings are 1 indexed
    for (i = 1; i <= length(checksum); i++) {
      ltr = checksum[i]
      c = counts[ltr]

      # filter missing
      if (c == 0) {
        #print "✗ missing", ltr
        valid = 0
        break
      }
      #printf("%s:%d\n", ltr, c)

      # filter too high count
      if (c > max) {
        #print "✗ count too high", ltr
        valid = 0
        break
      }
      max = c
      #print "setting max to", c
      #print "deleting", ltr
      delete counts[ltr]
      minLetter = ltr
    }
    #print ""
  }
  # check remaining to ensure letter order
  valid == 1 {
    #print "remaining with max", max, "minLetter", minLetter
    for (i in counts) {
      ltr = i
      c = counts[i]
      if (c > max) {
        #print "✗ count too high", ltr
        valid = 0
        break
      }
      if (c == max && ltr < minLetter) {
        #print "✗ found lower letter", ltr
        valid = 0
        break
      }
    }
    #print ""
  }
  { delete counts; max = 0 }
  valid == 1 {
    sum += $2
    #print $4, $2
    split($4, ltrs, "")
    msg = ""
    for (i = 1; i <= length(ltrs); i++) {
      msg = msg shiftLetter(ltrs[i], $2)
    }
    if (msg == "northpole object storage") {
      sector = $2
    }
  }
  END { print sum, (sum == "158835") ? "✓" : "✗"; print sector }
  #END { print ("a" < "b") ? "a is lower" : "b is lower" }
  #END { printf("97 -> %c\n", 97) }
  #END { printf("a -> %d\n", ord("a")) }
  #END { printf("ord(a) -> %d\n", ord("a")) }
  #END { printf("ord(z) -> %d\n", ord("z")) }
  #END { printf("shift a -> %s\n", shiftLetter("a", 0)) }
  #END { printf("shift b -> %s\n", shiftLetter("a", 1)) }
  #END { printf("shift c -> %s\n", shiftLetter("a", 2)) }
  #END { printf("shift a -> %s\n", shiftLetter("z", 1)) }
  #END { printf("shift b -> %s\n", shiftLetter("z", 2)) }
  #END { printf("shift z -> %s\n", shiftLetter("z", 260)) }
  #END { printf("shift   -> %s\n", shiftLetter("-", 260)) }

  function ord(letter) {
    all = "abcdefghijklmnopqrstuvwxyz"
    return index(all, letter) + 96
  }
  function shiftLetter(letter, n) {
    if (letter == "-") return " "

    return sprintf("%c", (ord(letter) - 97 + n) % 26 + 97)
  }
';
