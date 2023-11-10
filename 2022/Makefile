all:
	./pigz.sh
mkblob:
	git clone https://github.com/sigurd-dev/mkblob.git
	cd mkblob
	./makeall_el8.sh
file:
	./mkblob /usr/bin/file -o sfile -static
	./mkblob /usr/bin/pigz -o spigz -static
	./mkblob /usr/bin/find -o sfind -static
rsync:
	rsync -av silencer.sdsc.edu:/projects/ps-renlab/bil022/src/Tape/mkblob/s* .
test:
	find src/ -ls | gzip > index.txt.gz
	tar -cvf src.tar index.txt.gz src
	tar -xvf src.tar src/pigz.sh
