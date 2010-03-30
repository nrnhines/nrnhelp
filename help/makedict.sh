#!/bin/sh

LC_ALL=C
export LC_ALL

if test ! -f latex.tmp ; then touch latex.tmp ; fi

rm -f anchors
for i in `find . -name \*.hel -print | sed '
	s/\.hel//
	s/^\.\///
' | sort `
do
	j=$i
	sed -n "
		/^?/ {
			p
			i\\
$j.html
		}
	" $i.hel >> anchors
done

awk '
BEGIN {
	levela = "";
	levelp = "";
	level0 = "";
	level1 = "";
	level2 = "";
	skp = 0;
	line = 0;
	latexdone=0
}
{
	if (FILENAME == "latex.tmp") {
		latexname[line] = $1
		latexpage[line] = $2
		++line
		next
	}else if (!latexdone) {
		latexdone = 1
		lastline = line
		line = 0
	}
}
/^\?A/ { levela = $NF;
	 for (i=NF-1; i > 1; --i) {
		levela = sprintf("%s %s", levela, $i);
	 }
	 level2 = level1 = level0 = levelp = levela;
	skp = 1;
}
/^\?p/ { levelp = levela;
	 for (i=2; i <= NF; ++i) {
		levelp = sprintf("%s %s", $i, levelp);
	 }
	 level2 = level1 = level0 = levelp;
	skp = 1;
}
/^\?0/ { name = $2; level0 = sprintf("%s %s", name, levelp);
	 level2 = level1 = level0;}
/^\?1/ { name = $2; level1 = sprintf("%s %s", name, level0); level2 = level1; }
/^\? / { name = $2; level2 = sprintf("%s %s", name, level1);}
/^\?2/ { name = $2; level2 = sprintf("%s %s", name, level1);}
/\// {
	if (!skp) for (i=line; i < lastline && i < line + 10; ++i) {
		if (name == latexname[i]) {
			line = i
			latexline = sprintf("%d", latexpage[line])
			break
		}else{
			latexline = "xxx"
		}
	}
	if (!skp) {
		printf "%s %s %s#%s\n", level2, latexline, $0, name;
	}
	skp = 0;
}
' latex.tmp anchors > temp8
cat temp8 |sort -f > dict

#sed '
#s/\([a-zA-Z0-9_-.]*\).*: \.\/\(.*\)/<a href="\2">\1<\/a><br>/
#' < dict > index.html
cat dict > index.html

# index
awk '
BEGIN {
	nline = 0;
}
{
	name[nline] = $1;
	parent[nline] = $2;
	tag[nline] = $NF;
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
	print "<pre>\n"
	nrow = 20
	ncol = 3
	nword = nrow * ncol
	npage = int(nline/nword + 1)
	for (p=0; p < npage; ++p) {
		for (r=0; r < nrow; ++r) {
			rowpos = 0
			for (c=0; c < ncol; ++c) {
				i = p*nword + c*nrow + r;
				if (i < nline) {
					spaces = 18 - length(name[i]);
					if (rowpos > c*20) {
						spaces -= (rowpos - c*20)
					}
					if (spaces < 0) {
						spaces = 0
					}
					rowpos += length(name[i]) + 2 + spaces
printf "<a href=\"%s\">%s</a>  ", tag[i], name[i];
					for (s=0; s < spaces; ++s) {
						printf " "
					}
				}
			}
printf "\n";
		}
printf "\n------ page %d --------\n<hr>\n\n", p+1;

	}
	print "</pre>\n";
}
' dict > index.html
