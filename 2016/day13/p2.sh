#!/bin/bash

fn="sample.txt" x2=7 y2=4
fn="input.txt" x2=31 y2=39

<"$fn" awk -v x2=$x2 -v y2=$y2 '
function d2b(d,  b) {
  while(d) {
    b=d%2b
    d=int(d/2)
  }
  return(b)
}

# manhattan distance
function h(x, y, x2, y2) {
  return sqrt((x2 - x)^2 + (y2 - y)^2)
}

function is_wall(x, y, _sum, _bin, _bits) {
  _sum = x*x + 3*x + 2*x*y + y + y*y + fav
  _bin = d2b(_sum)
  gsub(/0/, "", _bin)
  _bits = length(_bin)
  #print _sum, _bin, _bits

  return _bits % 2 == 0 ? 0 : 1
}

function is_empty(arr, idx) {
  for (idx in arr) {
    return 0
  }

  return 1
}

function min_f_score(_min) {
  _min_score = 9999999
  for (idx in open) {
    #print "idx", idx, fScore[idx]
    if (fScore[idx] < _min_score) {
      _min_score = fScore[idx]
      _min = idx
    }
  }

  #print "min", _min

  if (!_min) {
    print "empty"
    exit
  }

  return _min
}

BEGIN {
  # start
  x=1; y=1;

  # goal
  #goal = x2 SUBSEP y2

  # neighbours
  nx[0] =  1; ny[0] =  0
  nx[1] = -1; ny[1] =  0
  nx[2] =  0; ny[2] =  1
  nx[3] =  0; ny[3] = -1
}

{ fav = $1 }

END {
  # neighbours

  # A-star
  # f(n) = g(n) + h(n)
  gScore[x,y] = 0
  fScore[x,y] = 0
  open[x,y] = fScore[x,y]

  while (!is_empty(open)) {
    current = min_f_score()
    #print "current", current
    #if (current == goal) {
    #  print "found goal"
    #  break
    #}
    delete open[current]

    split(current, c, SUBSEP)

    # neighbours
    for (i = 0; i < 4; i++) {
      vx = c[1] + nx[i]
      vy = c[2] + ny[i]
      #print "neighbour", vx, vy
      # negative coordinates are invalid
      if (vx < 0 || vy < 0) {
        continue
      }

      if (is_wall(vx, vy)) {
        continue
      }

      # visit
      neighbour = vx SUBSEP vy
      # d(current, neighbour) = 1
      # each neighbour in a grid is only 1 distance unit away
      score = gScore[current] + 1
      if (score <= 50 && (!(neighbour in gScore) || score < gScore[neighbour])) {
        cameFrom[neighbour] = current
        gScore[neighbour] = score
        fScore[neighbour] = gScore[neighbour]
        if (!(neighbour in open)) {
          open[neighbour] = fScore[neighbour]
        }
      }
    }
  }

  # using length on an array might not be portable but mac OS awk supports it
  # for (i in gScore) n++
  print "Part 2:", length(gScore)
}

#END { print d2b(fav) }
'
