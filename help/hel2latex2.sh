#!/bin/sh

files=temp

if [ -f err.tmp ] ; then
	rm err.tmp
fi

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
' | sort | sed 's/  A  /  /' > dict.tmp
awk '
BEGIN {
	nfile = 0
	n=0
	level[0] = 1
	maxlev = 0
	dfil = "dict.tmp"
	fil = dfil
	levela = levelp = ""
}
{	if (FILENAME == dfil) {
	name[n] = $(NF-1)
	anchor[n] = $NF
	level[NF-1] = n
	if (NF == 2) {
		iparent = -1
	}else{
		iparent = level[NF-2]
	}
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
}
{
	if (fil != FILENAME) {
		fil = FILENAME
		prefix = substr(FILENAME, 1, length(FILENAME)-4)
		hfile = "temp2"
		nfpath = split(prefix, fpath, "/")
		++nfile
		realfile = prefix ".html"
	}
}
/^\?A/ { level1 = level0 = levelp = levela = $NF ; next}
/^\?p/ { level1 = level0 = levelp = $NF ; next}
/^\?[0-2 ]/ {
	if ($1 == "?0") { level1 = level0 = $ 2; qp = levelp}
	if ($1 == "?1") { level1 = $2 ; qp = level0}
	if ($1 == "?2") { qp = level1}
	if ($1 == "?") {  qp = level1}
	
	print "\\begin{verbatim}" >hfile
	i = assoc[$2]
	if (aldef[i]) {
#		print $2 " ambiguous at line " NR " of file:" FILENAME >"err.tmp"
		i = assoc[$2 "#" qp]
		if (!i) {
			print "Cant disambiguate with ", $2 "#" qp >"err.tmp"
			print "in " FILENAME >"err.tmp"
		}
	}
#	if (aldef[i]) {
#		print $2 " ambiguous at line " NR " of file:" FILENAME >"err.tmp"
#	}
	p = parent[i]
	if (p != -1) {
		printf("%s (%d)\n", name[p], anchor[p]) > hfile
	}

			if (nchild[i]) {
				k=0
				for (j=firstchild[i]; j >= 0; j = nextchild[j]) {
					children[k++] = j
				}
	
				ncol = 4
				nrow = int(nchild[i]/ncol)
				if ((nrow*ncol) < nchild[i]) {
					++nrow
				}
				for (ix=0; ix < nrow; ++ix) {
						printf("   ") >hfile
					rowpos = 0
					for (iy=0; iy < ncol; ++iy) {
						j = nrow*iy + ix
						if (j < nchild[i]) {
							x = children[j]

printf("%s (%d)  ", name[x], anchor[x]) >hfile
rowpos += length(name[x]) + 2
spaces = 15*(iy+1) - rowpos
if (spaces < 0) {
	spaces = 0
}
rowpos += spaces
for (s=0; s < spaces; ++s) {
	printf " " >hfile
}
						}
					}
					printf ("\n") >hfile
				}
			}

	print "\\end{verbatim}" >hfile
	next
}
/\@a/ {
	for (i=1; i <= NF; ++i) {
		m = index($i, "@a")
		if (m) {
			$i = substr($i, 3, length($i)-2)
			pos = index($i, ",")
			if (pos) {
				$i = substr($i, 1, pos-1)
			}
			j = assoc[$i]
			if (j < 0) {
print "Cant find " $i " at line " NR " of file:" FILENAME >"err.tmp"
			}
			$i = sprintf("%s (%d)", name[j], anchor[j])
		}
	}
}
{
	print $0 >hfile
}				

END {
}
' dict.tmp  $files

if [ -f err.tmp ] ; then
	cat err.tmp
fi
