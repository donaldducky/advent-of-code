#!/bin/bash

fn="sample.txt" input="abcde"
fn="input.txt" input="abcdefgh"

<"$fn" awk -v input="$input" '
function scramble(input, o, letters, n, t, i) {
  output = input

  split(input, letters, "")
  n = length(input)

  for (o = 1; o <= ops_count; o++) {
    op = ops[o]
    split(op, t)

    if (op ~ /swap position/) {
      a = t[3]
      b = t[6]

      h = letters[a + 1]
      letters[a + 1] = letters[b + 1]
      letters[b + 1] = h

    } else if (op ~ /swap letter/) {
      a = t[3]
      b = t[6]

      for (i = 1; i <= n; i++) {
        if (letters[i] == a) letters[i] = b
        else if (letters[i] == b) letters[i] = a
      }

    } else if (op ~ /reverse positions/) {
      si = t[3]
      ei = t[5]

      j = ei + 1
      for (i = si; i <= ei; i++) {
        #print i + 1, letters[i+1], j
        swap[j] = letters[i+1]
        j--
      }
      for (i in swap) {
        letters[i] = swap[i]
      }
      delete swap

    } else if (op ~ /rotate left/) {
      r=t[3]

      s=""
      for (i = 1; i <= n; i++) {
        s=s letters[i]
      }

      while (r) {
        s = substr(s, 2, n-1) substr(s, 1, 1)
        r--
      }
      split(s, letters, "")

    } else if (op ~ /rotate right/) {
      r=t[3]
      s=""
      for (i = 1; i <= n; i++) {
        s=s letters[i]
      }

      while (r) {
        s = substr(s, n, 1) substr(s, 1, n-1)
        r--
      }
      split(s, letters, "")

    } else if (op ~ /move position/) {
      from=t[3]
      to=t[6]

      popped = letters[t[3]+1]
      for (i = from; i < n; i++) {
        letters[i+1] = letters[i+2]
      }
      for (i = n; i > to; i--) {
        letters[i] = letters[i - 1]
      }
      letters[to + 1] = popped

    } else if (op ~ /rotate based/) {
      a = t[7]

      for (i in letters) {
        if (letters[i] == a) {
          idx = i - 1
          break;
        }
      }
      r = idx >= 4 ? 2 + idx : 1 + idx

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

  }

  s=""
  for (i = 1; i <= n; i++) {
    s=s letters[i]
  }

  #print s

  return s
}

# initialize data structure
#
# we expect input string to be sorted, at this point
#
# creates:
# - pn = number of letters
# - pletters = letters in order
# - pdirs = direction of each letter
function init_permutations(input, _letters, _i) {
  pn = length(input)
  split(input, _letters, "")

  for (_i = 1; _i <= pn; _i++) {
    pletters[_i] = _letters[_i]
    pdirs[_i] = "L"
  }
}

function permute(_i, _s, _mobile, _dir, _cur, _left, _right, _lg, _lg_i, _swap_i, _temp) {
  #print ""
  #for (_i = 1; _i <= pn; _i++) {
  #  printf("%s ", pdirs[_i] == "L" ? "←": "→")
  #}
  #print ""
  #for (_i = 1; _i <= pn; _i++) {
  #  printf("%s ", pletters[_i])
  #}
  #print ""
  if (pdone) {
    return ""
  }

  # return current permutation and create next
  _s=""
  for (_i = 1; _i <= pn; _i++) {
    _s = _s pletters[_i]
  }

  # calculate next permutation using Steinhaus-Johnson-Trotter
  # 1. find largest mobile component
  _lg = ""
  _lg_idx = 0
  for (_i = 1; _i <= pn; _i++) {
    _dir = pdirs[_i]
    _cur = pletters[_i]
    _left = pletters[_i - 1]
    _right = pletters[_i + 1]
    _mobile = 0

    # is mobile?
    if (_dir == "L" && _i > 1 && _cur > _left) {
      _mobile = 1
    } else if (_dir == "R" && _i < pn && _cur > _right) {
      _mobile = 1
    }

    #print _i, _left, "("_cur, _dir ")", _right, "mobile?", _mobile


    if (_mobile && pletters[_i] > _lg) {
      _lg = pletters[_i]
      _lg_i = _i
      _swap_i = pdirs[_i] == "L" ? _i - 1 : _i + 1
    }
  }
  if (!_lg) {
    pdone = 1
  }
  #print "largest mobile component", _lg, _lg_i, _swap_i

  # 2. swap it with component it points to
  _temp = pletters[_lg_i]
  pletters[_lg_i] = pletters[_swap_i]
  pletters[_swap_i] = _temp
  _temp = pdirs[_lg_i]
  pdirs[_lg_i] = pdirs[_swap_i]
  pdirs[_swap_i] = _temp

  # 3. if there are larger values, change their directions
  for (_i = 1; _i <= pn; _i++) {
    #print pletters[_i], pletters[_lg_i]
    if (pletters[_i] > pletters[_swap_i]) {
      #print "swapping direction"
      pdirs[_i] = pdirs[_i] == "L" ? "R" : "L"
    }
  }

  return _s
}

{ ops[NR] = $0 }

END {
  ops_count = NR

  #print "scrambled", scramble(input)

  out = "fbgdceah"

  # brute force, since we know our scrambling works
  # length(input) = 8
  # 8! = 40320 permutations
  init_permutations(input)
  cnt = 0
  do {
    cnt++
    if (cnt % 1000 == 0) print cnt
    perm = permute()
    if (seen[perm]) {
      print "dupe!"
      exit
    }
    seen[perm] = 1
    scrambled = scramble(perm)
    #print "perm="perm, "scrambled="scrambled
    if (scrambled == out) {
      print "Part 2:", perm
      exit
    }
  } while (perm)
}
'
