#!/bin/bash

<input.txt tr '[]' '@@' | awk -F '@' '
{
  for (i=1;i<=NF;i++) {
    if ($i == "") continue
    if (i%2==1) {
      a=a " " $i
    } else {
      b=b " " $i
    }
  }
}
{ print a ":" b }
{ a=""; b="" }
' | rg --pcre2 '(\w)(?!\1)(\w)\1[^:]*:.*\2\1\2' | wc -l
