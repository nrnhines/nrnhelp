#!/bin/sh

hoc_e + temp2 << here
ec1
:
: mark all text lines with !
gs/^/!/
g/\\begin{verbatim}/.+1,/\\end{verbatim}/-1s/^!//
: hide special text characters
g/^!/s/_/@!_/g
g/^!/s/\\#/@!#/g
:
gs/@!/\\\\/g
gs/^!//
:
w temp3
q
here
