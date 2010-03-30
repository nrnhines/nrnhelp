#!/bin/sh
awk '
BEGIN {
	cnt = -1
	line = 0
}
{
	++line
}
/^\\section/ {
	if (cnt != 0) {
		print line
		exit
	}
}

/\\begin/ {
	++cnt
}
/\\end/ {
	--cnt
}
' < temp.tex

