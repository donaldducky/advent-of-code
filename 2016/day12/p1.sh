#!/bin/bash

fn="sample.txt"
fn="input.txt"

<"$fn" awk '
BEGIN {
r["a"]=0
r["b"]=0
r["c"]=0
r["d"]=0
}
{ ins[NR]=$0 }

END {
  last_in = NR
  ip = 1
  halted = 0

  max=10000
  while (!halted) {
    i++
    if (i > max) {
      print "exiting, too many iterations"
      exit
    }
    instruction = ins[ip]
    split(instruction, _in, " ")

    #print ip, instruction, "\ta=" r["a"], "b=" r["b"], "c=" r["c"], "d=" r["d"]

    # short circuit the loops
    if (ip == 9) {
      r["d"] += r["c"]
      r["c"] = 0
      ip++
    } else if(ip == 13) {
      r["a"] += r["b"]
      r["b"] = 0
      ip++
    } else {
      # need gawk for switch statements
      if (_in[1] == "cpy") {
        v = _in[2] ~ /[a-d]/ ? r[_in[2]] : _in[2]
        r[_in[3]] = v
        ip++
      } else if (_in[1] == "inc") {
        r[_in[2]]++
        ip++
      } else if (_in[1] == "dec") {
        r[_in[2]]--
        ip++
      } else if (_in[1] == "jnz") {
        v = _in[2] ~ /[a-d]/ ? r[_in[2]] : _in[2]
        if (v != 0) {
          ip += _in[3]
        } else {
          ip++
        }
      } else {
        print "Unhandled instruction:", instruction
        exit
      }
    }
    if (ip > last_in) {
      halted = 1
    }
  }

  print r["a"]
}
'
