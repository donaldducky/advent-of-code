#!/bin/bash

<input.txt rg --pcre2 -v '\[[^\]]*([a-z])(?!\1)([a-z])\2\1[^\]]*]' | rg --pcre2 '(\w)(?!\1)(\w)\2\1' | wc -l
