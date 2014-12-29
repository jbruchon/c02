all:
	acme -v3 main.s | tee build.log

clean:
	rm -f *.o build.log ksyms.txt

