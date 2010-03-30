#!/bin/sh

LC_ALL=C
export LC_ALL

d='.'
rm -f temp0
cat `find $d -name \*.hel -print | sort` > temp0
./hel2latex1.sh temp0
./hel2latex2.sh
./hel2latex3.sh
cp temp3 latexbook/temp.tex

