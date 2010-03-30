#!/bin/sh

D=`dirname $1`
hoc_e + "$1" << here
ec1
:
: mark all text lines with !
gs/^/!/
g/^@code/.+1,/^@endcode/-1s/^!//
: hide special text characters
g/^!/s/\\^/@!verb+^+/g
g/^!/s/\\&/@!&/g
g/^!/s/\\%/@!%/g
g/^!/s/\\\\/@!verb+@!+/g
g/^!/s/\\$/@!$/g
:
gs/^!@/@/
gs/^!?/?/
: handle execcode
g/@execcode/.,/@code/-1d
: special characters
:
: standard form
1,\$s/^? /?2 /
:
: synopsis format
g/^@hsyn/.+1,/^@h/-1s/!\\(.*\\)/{@!tt \\1}@!@!/
: all words in "see also" are anchors
g/^@hsee/.+1,/^@h/-1s/\\([a-zA-Z][a-zA-Z0-9_-.#]*\\)/@a\\1 /g

:
: major headers
1,\$s/^@hname/@!subsubsection* {NAME}/
1,\$s/^@hsyn/@!subsubsection* {SYNTAX}/
1,\$s/^@hdesc/@!subsubsection* {DESCRIPTION}/
1,\$s/^@hopt/@!subsubsection* {OPTIONS}/
1,\$s/^@hex/@!subsubsection* {EXAMPLES}/
1,\$s/^@hdiag/@!subsubsection* {DIAGNOSTICS}/
1,\$s/^@hbug/@!subsubsection* {BUGS}/
1,\$s/^@hsee/@!subsubsection* {SEE ALSO}/
g/^@h/d
:
: inline code snippets
gs/%/@percent/g
gs/@}/%/g
gs/@{\\([^%]*\\)%/{@!tt \\1}/g
gs/@percent/%/g
: metasyntactic words
1,\$s/@var\\([a-zA-Z0-9_-.]*\\)/{@!em \\1}/g
: descriptive lists
1,\$s/@dl/@!begin{description}/
1,\$s/@dt \\(.*\\)/@!item{\\1}/
1,\$s/@dd//
1,\$s/@endl/@!end{description}/
:
: surround fragments with ?# @end# and create name= anchor
1,\$s/^?\\([0-9]\\)[ 	]*\\(.*\\)/@@end\\1\\
@!section*{\\2 @!index{\\2}}\\
?\\1 \\2
\$a.@@end3
:
g/@@end/m/@@end/-1
/@@end3/d
:
: hide preformatted text
g/^@code/.+1,/^@endcode/-1s/^\$/@@/
:
: html formats
gs/<h2> *\\(.*\\) *<.*/@!subsection*{\\1}/
gs/<br>/@!@!/
gs/@br/@!@!/
:
1,\$s/^@code/@!begin{quote} @!begin{verbatim}/
1,\$s/^@endcode/@!end{verbatim}@!end{quote}/
: table
1,\$s/^@table/@!begin{verbatim}/
1,\$s/^@endtable/@!end{verbatim}/
1,\$s/^@pre/@!begin{verbatim}/
1,\$s/^@endpre/@!end{verbatim}/
1,\$s/@@end.*//
: cleanup
g/^@@end/d
1,\$s/^@@\$//
:
1i
@!chapter*{NEURON Reference}
.
:
gs/@!/\\\\/g
gs/^!//
:
w temp
q
here
