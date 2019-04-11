#!/bin/bash
FILE=$1
dos2unix $FILE
awk -F, 'NR==1 {h=$0; next} {f=$2".fragment.csv"} !($2 in p) {p[$2]; print h > f} {print >> f}' $FILE
