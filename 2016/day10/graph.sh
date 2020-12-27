#!/bin/bash

rg '^bot' input.txt | awk 'BEGIN { print "graph a {" } { print "bot" $2 " -- " $6$7 " [label=\"" $4 "\"];" } { print "bot" $2 " -- " $11$12 " [label=\"" $9 "\"];" } END { print "}" }' > graph.dot
dot -Tpng graph.dot > graph.png
