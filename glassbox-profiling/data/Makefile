
default:
	cat mem.*.csv | head -n 1 > header.tmp
	cat mem.*.csv | grep -v "PID" | sort -t, -k2,2 -k1,1n > mem.grouped.tmp
	cat header.tmp mem.grouped.tmp > mem.grouped.csv
	./split_data.sh mem.grouped.csv
	gnuplot plot.gnuplot

open:
	xdg-open output.eps &

clean:
	rm header.tmp
	rm mem.grouped.tmp
	rm mem.grouped.csv
	rm *.fragment.csv
	rm *.eps


.PHONY: default open clean
