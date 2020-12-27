#!/bin/bash

fn="sample.txt"
fn="input.txt"

<"$fn" awk '

function add_instruction(bot_id, lo_dest, lo_id, high_dest, high_id) {
  ins[bot_id] = lo_dest "," lo_id "," high_dest "," high_id
}

function give_bot(bot_id, val) {
  if (botn[bot_id] == 0) {
    bots[bot_id]=val
  } else {
    bots[bot_id]=bots[bot_id] "," val
  }
  botn[bot_id]++
  if (botn[bot_id] == 2) {
    add_next_bot(bot_id)
  }
}

function has_next() {
  return has_two != ""
}

function add_next_bot(bot_id) {
  if (has_next()) {
    has_two = has_two "," bot_id
  } else {
    has_two = bot_id
  }
}

function give_output(out_id, val) {
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

function next_bot(_twos) {
  split(has_two, _twos, ",")
  has_two=""
  for (i in _twos) {
    if (i != 1) {
      add_next_bot(_twos[i])
    }
  }

  return _twos[1]
}

function take_chips(bot_id, _chips) {
  split(bots[bot_id], _chips, ",")
  if (_chips[1] > _chips[2]) {
    lo = _chips[2]
    hi = _chips[1]
  } else {
    hi = _chips[2]
    lo = _chips[1]
  }

  bots[bot_id]=""
  botn[bot_id]=0
}

function give_chip(type, id, chip) {
  if (type == "bot") {
    give_bot(id, chip)
  } else {
    give_output(id, chip)
  }
}

$1 == "value" { give_bot($6, $2) }
$1 == "bot" { add_instruction($2, $6, $7, $11, $12) }

END {
  while (has_next()) {
    cur = next_bot()

    # sets lo_d, lo_v, hi_d, hi_v
    get_instruction(cur)

    # sets lo, hi
    # clears chips from bots
    take_chips(cur)

    if (lo == 61 && hi == 17 || lo == 17 && hi == 61) {
      print "Part 1:", cur
      exit
    }

    give_chip(lo_d, lo_v, lo)
    give_chip(hi_d, hi_v, hi)
  }
}
'
