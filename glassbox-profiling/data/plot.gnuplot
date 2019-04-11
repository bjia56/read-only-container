LABELS = system("cat mem.grouped.csv | cut -d ',' -f1,2 | awk -F ':' '{printf(\"%s \", $NF); for (i=1; i<=NF-1; i++) {printf(\"%s\", $i); if (i<NF-1) printf \":\"} print \"\"}' | sort -t ' ' -k1,1n -k2,2n | awk '{print $2,$1}' | cut -d ',' -f2 | sed -e 's/ /:/' | uniq")
set datafile separator ","
set key autotitle columnhead
set term postscript enhanced color font 'Verdana' size 24,10
set output "output.ps"
set key outside
plot for [i=1:words(LABELS)] sprintf("%s.fragment.csv", word(LABELS,i)) u 1:3 with linespoints pointinterval 100 title word(LABELS,i) noenhanced