
default:
	./split_data.sh mem.*.csv
	gnuplot plot.gnuplot

open:
	xdg-open output.ps &

clean:
	rm *.fragment.csv
	rm *.ps


.PHONY: default open clean
