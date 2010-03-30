#!/bin/sh

LC_ALL=C
export LC_ALL

/bin/rm -f err.tmp

< dict awk '
{
	line = "";
	name = $1;
	for (i = NF - 2; i > 0; --i) {
		line = line " " $i
	}
	line = line "  A  " $NF
	print line
}
' | sort | sed 's/  A  /  /' > dict.tmp
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
	printf("<pre>\n")
	for (i=1; i <= maxlev; ++i) {
		nlevel[i] = 0
	}
	for (i=0; i < n ; ++i) {
		++nlevel[lev[i]]
	}
	nl = 0
	for (i=1; i <= maxlev; ++i) {
		nl = nl + nlevel[i]
		if (nl > 40) {
			break
		}
	}
	nl = i
	for (i=0; i<n; ++i) {
		if (lev[i] < nl) {
			for (j=0; j < lev[i]; ++j) {
				printf("   ")
			}
			printf("<a href=\"%s\">", anchor[i])
			printf("%s", name[i])
			printf("</a>\n")
			isprinted[i] = 1
			if (lev[i] == nl-1 && nchild[i]) {
				k=0
				for (j=firstchild[i]; j >= 0; j = nextchild[j]) {
					children[k++] = j
				}
	
				ncol = 3
				nrow = int(nchild[i]/ncol)
				if (nrow > 7) {
					continue
				}
				if ((nrow*ncol) < nchild[i]) {
					++nrow
				}
				for (ix=0; ix < nrow; ++ix) {
					rowpos = 0
					for (j=0; j < lev[i]+1; ++j) {
						printf("   ")
					}
					for (iy=0; iy < ncol; ++iy) {
						j = nrow*iy + ix
						if (j < nchild[i]) {
							x = children[j]

printf("<a href=\"%s\">%s</a>  ", anchor[x], name[x])
rowpos += length(name[x]) + 2
spaces = 15*(iy+1) - rowpos
if (spaces < 0) {
	spaces = 0
}
rowpos += spaces
for (s=0; s < spaces; ++s) {
	printf " "
}
						}
					}
					printf ("\n")
				}
			}
                }   
	}
	printf("</pre>\n")
}
' dict.tmp > hier.html

if [ -f err.tmp ] ; then
	cat err.tmp
fi
        
