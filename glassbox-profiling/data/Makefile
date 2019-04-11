
default:
	cat mem.*.csv | grep -v "PID" | sort -t, -k2,2 -k1,1n > mem.grouped.csv
	./split_data.sh mem.grouped.csv
	gnuplot plot.gnuplot

open:
	xdg-open output.ps &

clean:
	rm mem.grouped.csv
	rm *.fragment.csv
	rm *.ps


.PHONY: default open clean
