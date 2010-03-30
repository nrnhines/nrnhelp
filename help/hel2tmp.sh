#!/bin/sh

rm -f temp5
D=`dirname $1`
fdate=`ls -l $1.hel | awk '{print $NF " : " $6 " " $7 " " $8}'`

hoc_e + "$1".hel << here
ec1
:
: handle execcode
gs;^@code;//@code;
1,\$s;@execcode \\(.*\\);@execcode \\1.hoc\\
cat - > ${D}\\/\\1.hoc << '@endcode';
g/@execcode/.+1,/^@endcode/ ww temp5
gs/^\\/\\/@code/@code/
g/@execcode/.+1,/@code/-1d
gs/@execcode \\(.*\\)/<a href="\\1">execute following example<\\/a>
: special characters
g/@code/.,/@endcode/s/\\&/\\&amp;/g
g/@code/.,/@endcode/s/\\</\\&lt;/g
g/@code/.,/@endcode/s/\\>/\\&gt;/g
gs/@\\&/\\&amp;/g
gs/@\\</\\&lt;/g
gs/@\\>/\\&gt;/g
:
: standard form
gs/^? /?2 /
:
: synopsis format
g/^@hsyn/.+1,/^@h/-1s/\\(.*\\)/<code>\\1<\\/code><br>/
: all words in "see also" are anchors
g/^@hsee/.+1,/^@h/-1s/\\([a-zA-Z][a-zA-Z0-9_-.#]*\\)/@a\\1 /g
:
: major headers
gs/^@hname/<h2>NAME<\\/h2>/
gs/^@hsyn/<h2>SYNTAX<\\/h2>/
gs/^@hdesc/<h2>DESCRIPTION<\\/h2>/
gs/^@hopt/<h2>OPTIONS<\\/h2>/
gs/^@hex/<h2>EXAMPLES<\\/h2>/
gs/^@hdiag/<h2>DIAGNOSTICS<\\/h2>/
gs/^@hbug/<h2>BUGS<\\/h2>/
gs/^@hsee/<h2>SEE ALSO<\\/h2>/
g/^@h/d
:
: inline code snippets
gs/%/@percent/g
gs/@}/%/g
gs/@{\\([^%]*\\)%/<code>\\1<\\/code>/g
gs/@percent/%/g
: metasyntactic words
gs/@var\\([a-zA-Z0-9_-.]*\\)/<var>\\1<\\/var>/g
: descriptive lists
gs/@dl/<dl>/g
gs/@dt/<dt>/g
gs/@dd/<dd>/g
gs/@endl/<\\/dl>/g
:
: surround fragments with ?# @end# and create name= anchor
1,\$s/^?\\([0-9]\\)[ 	]*\\(.*\\)/@@end\\1\\
<h1><a name="\\2">\\2<\\/a><\\/h1>\\
?\\1 \\2
\$a.@@end3
:
g/@@end/m/@@end/-1
/@@end3/d
:
: hide preformatted text
g/^@code/.+1,/^@endcode/-1s/^\$/@@/
:
gs/^\$/<p>/
gs/^@code/<blockquote><pre>/
gs/^@endcode/<\\/pre><\\/blockquote>/
: table
gs/^@table/<pre>/
gs/^@endtable/<\\/pre>/
gs/^@pre/<pre>/
gs/^@endpre/<\\/pre>/
gs/@@end.*/<p><hr><p>
: cleanup
g/^@@end/d
gs/^@@\$//
:
\$a
<date>
$fdate
.
w temp
q
here
mv temp $1.tmp
if [ -f temp5 ] ; then
	chmod 755 temp5
	./temp5
fi
