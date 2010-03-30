#!/bin/sh
# zip up this part of the web site. Should be extracted into
# http://www.neuron.yale.edu/neuron/docs
# so that the help and refman subdirectories are created there.
rm help.zip
zip help.zip `find help -name \*.html -print`
zip help.zip `find help -name \*.hoc -print`
zip help.zip `find help -name \*.txt -print`
zip help.zip `find refman -name \*.html -print`
zip help.zip `find refman -name \*.ps -print`
zip help.zip helpfils.html

scp help.zip hines@www.neuron.yale.edu:/home/htdocs/neuron/static/docs/nrnhelp.zip
ssh hines@www.neuron.yale.edu "cd /home/htdocs/neuron/static/docs ; unzip -o nrnhelp.zip"

