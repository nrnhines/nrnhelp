#!/bin/sh

LC_ALL=C
export LC_ALL

< dict awk '
{
	line = "";
	name = $1;
	for (i = NF - 2; i > 0; --i) {
		line = line " " $i
	}
	line = line "  A  " $(NF-1)
	print line
}
' | sort | sed 's/  A  /  /'> dict.tmp
awk '
BEGIN {
	n=0
	level[0] = 1
	maxlev = 0
}
{
	name[n] = $(NF-1)
	anchor[n] = $NF
	level[NF-1] = n
	iparent = level[NF-2]
	parent[n] = iparent
	if (assoc[name[n]]) {
		a = assoc[name[n]]
		assoc[name[n] "#" name[parent[n]]] = n
		assoc[name[a] "#" name[parent[a]]] = a
#printf "associating " name[n] "#" parent[n] " and " name[a] "#" parent[a] > "err.tmp"
		aldef[a] = 1
	}else{
		assoc[name[n]] = n
	}
	nchild[n] = 0
	lev[n] = NF-1
	if (maxlev < NF-1) {
		maxlev = NF-1
	}
	firstchild[n] = -1
	lastchild[n] = -1
	nextchild[n] = -1
	if (nchild[iparent] == 0) {
		firstchild[iparent] = n
	}else{
		nextchild[lastchild[iparent]] = n
	}
	lastchild[iparent] = n
	++nchild[iparent]

	++n
	next
}
END {
	print "\\section*{Contents}"
	print "\\begin{tabbing}"
	print "xxx \\= xxx \\= xxx \\= xxx \\= xxx \\= \\kill"
	for (i=1; i <= maxlev; ++i) {
		nlevel[i] = 0
	}
	for (i=0; i < n ; ++i) {
		++nlevel[lev[i]]
	}
	nl = 0
	for (i=1; i <= maxlev; ++i) {
		nl = nl + nlevel[i]
		if (nl > 30) {
			break
		}
	}
	nl = i
	for (i=0; i<n; ++i) {
		if (lev[i] < nl) {
			for (j=1; j < lev[i]; ++j) {
				printf(" \\> ")
			}
			print name[i] " (" anchor[i] ")\\\\"
			isprinted[i] = 1
			if (lev[i] == nl-1 && nchild[i]) {
				k=0
				for (j=firstchild[i]; j >= 0; j = nextchild[j]) {
					children[k++] = j
				}
	
				ncol = 2
				nrow = int(nchild[i]/ncol)
				if (nrow > 9 || nrow == 0) {
					continue
				}
print "xxx xxx xxx xxx \\= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \\= \\kill"
				if ((nrow*ncol) < nchild[i]) {
					++nrow
				}
				for (ix=0; ix < nrow; ++ix) {
					for (j=0; j < lev[i]+1; ++j) {
#						printf(" \\> ")
					}
					for (iy=0; iy < ncol; ++iy) {
						j = nrow*iy + ix
						if (j < nchild[i]) {
							x = children[j]

printf(" \\> %s (%s)", name[x], anchor[x])
						}
					}
print "\\\\"
					if (ix == nrow-1) {
print "xxx \\= xxx \\= xxx \\= xxx \\= xxx \\= \\kill"
					}
						
				}
			}
                }   
	}
	print "\\end{tabbing}"
}
' dict.tmp | sed '
	s/_/\\_/g
	s/-/ /g
' > latexbook/contents.tex

if [ -f err.tmp ] ; then
	cat err.tmp
fi
        
