#!/bin/sh

latexindex=latexbook/ref.idx

sed -n '
	/\\indexentry/s/._/_/g
	s/\\indexentry{\([a-zA-Z0-9./_-]*\).*}\([a-zA-Z0-9./_-]*\).*}\([a-zA-Z0-9./_-]*\)}{\([0-9]*\)}/\1_\2_\3 \4/p
	s/\\indexentry{\([a-zA-Z0-9./_-]*\).*}\([a-zA-Z0-9./_-]*\)}{\([0-9]*\)}/\1_\2 \3/p
	s/\\indexentry{\([a-zA-Z0-9./_-]*\)}{\([0-9]*\)}/\1 \2/p
' < $latexindex > latex.tmp
