./anchorindex.sh	# really needs a onefile a and latexbook/do first
./makedict.sh
./indexfilter.sh
./makecontents.sh
./allh2h

./maketexindex.sh
./maketexcontents.sh
./onefile.sh
cd latexbook
./doit

cd ..
./anchorindex.sh	# one more iteration so all refs are to correct
./makedict.sh	# page numbers
./maketexindex.sh
./maketexcontents.sh
./onefile.sh
cd latexbook
./doit

cd ..
sh quick_reference_maker.sh 0 0
