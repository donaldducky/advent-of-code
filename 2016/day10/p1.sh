#!/bin/bash

fn="sample.txt"
fn="input.txt"

<"$fn" awk '

function give_bot(bot_id, val) {
  print "give chip", val, "to bot", bot_id
  if (botn[bot_id] == 0) {
    bots[bot_id]=val
  } else {
    bots[bot_id]=bots[bot_id] "," val
  }
  botn[bot_id]++
  if (botn[bot_id] == 2) {
    if (has_two) {
      has_two = has_two "," bot_id
    } else {
      has_two = bot_id
    }
  }
  print "\tbot", bot_id, "chips:", bots[bot_id], "has two?", has_two
}

function give_output(out_id, val) {
  print "give chip", val, "to output", out_id
  if (out[out_id]) {
    out[out_id] = out[out_id] "," val
  } else {
    out[out_id] = val
  }
}

function get_instruction(bot_id, _o) {
  split(ins[bot_id], _o, ",")
  lo_d=_o[1]
  lo_v=_o[2]
  hi_d=_o[3]
  hi_v=_o[4]
}

function step(_chips, _lo, _hi, _twos) {
  print ""
  print has_two
  split(has_two, _twos, ",")
  has_two=""
  for (i in _twos) {
    if (i != 1) {
      if (has_two) {
        has_two = has_two "," _twos[i]
      } else {
        has_two = _twos[i]
      }
    }
  }
  cur=_twos[1]
  print "current bot", cur, "has_two", has_two

  split(bots[cur], _chips, ",")
  print "bot " cur " has two chips:", _chips[1], _chips[2]
  get_instruction(cur)
  #print lo_d, lo_v, hi_d, hi_v
  if (_chips[1] > _chips[2]) {
    _lo = _chips[2]
    _hi = _chips[1]
  } else {
    _hi = _chips[2]
    _lo = _chips[1]
  }
  if (_chips[1] == 61 && _chips[2] == 17 || _chips[1] == 17 && _chips[2] == 61) {
    print "Part 1:", cur
    exit
  }

  bots[cur]=""
  botn[cur]=0
  if (lo_d == "bot") {
    give_bot(lo_v, _lo)
  } else {
    give_output(lo_v, _lo)
  }
  if (hi_d == "bot") {
    give_bot(hi_v, _hi)
  } else {
    give_output(hi_v, _hi)
  }
}

#{print}

$1 == "value" { give_bot($6, $2) }

$1 == "bot" { ins[$2]=$6 "," $7 "," $11 "," $12 }

END {
  j = 0
  n = 1000
  while (has_two >= 0) {
    step()
    j++
    if (j > n) {
      print "too many iterations, exiting"
      exit
    }
  }

  for (i in out) {
    print "output", i, "contains", out[i]
  }
}
'
