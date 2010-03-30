#!/bin/sh

# index
awk '
BEGIN {
	nline = 0;
}
{
	name[nline] = $1;
	parent[nline] = $2;
	tag[nline] = $NF;
	page[nline] = $(NF-1)
	ns = nsame[$1]
	if (ns == 0) {
		assoc[$1] = nline
		nsame[$1] = 1
	}else if (ns == 1) {
		++nsame[$1]
		nl = assoc[$1]
		name[nl] = $1 "-" parent[nl]
		name[nline] = $1 "-" parent[nline]
	}else if (ns > 1) {
		name[nline] = $1 "-" parent[nline]
	}

	++nline;
}
END {
	print "\\twocolumn\n"
	print "\\section*{Index}"
	for (i=0; i < nline; ++i) {
		str = name[i] " (" page[i] ")\\\\"
		print str
	}
	print "\n\\onecolumn"
}
' dict | sed '
	s/_/\\_/g
	s/-/ /g
'> latexbook/index.tex
