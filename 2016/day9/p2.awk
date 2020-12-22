{
  d = 0
  s[0] = $1
  mx[0] = 1
  size=0

  do {
    print "depth=" d, "s=" s[d]
    where = match(s[d], /\([0-9]+x[0-9]+\)/)
    if (where != 0) {
      if (RSTART > 1) {
        print "found", substr(s[d], 1, RSTART - 1), "mx=" mx[d], "d=" d
        print " +", length(substr(s[d], 1, RSTART - 1)) * mx[d]
        size += length(substr(s[d], 1, RSTART - 1)) * mx[d]
      }
      m = substr(s[d], RSTART + 1, RLENGTH - 2)
      split(m, out, "x")
      r = substr(s[d], RLENGTH + RSTART, out[1])
      print "marker", m
      print "matched", r
      save[d] = substr(s[d], RSTART + RLENGTH + out[1], length(s[d]))
      print "d=" d, "after match", s[d]
      d++
      print ""
      s[d] = r
      mx[d] = out[2] * mx[d-1]
    } else {
      print "done", s[d], mx[d]
      print " +", length(s[d]) * mx[d]
      size += length(s[d]) * mx[d]
      s[d] = ""
      d--
      s[d] = save[d]
      print "d=" d, "s[d]=" s[d]
    }
  } while (length(s[0]))

  print "Part 2:", size
}
