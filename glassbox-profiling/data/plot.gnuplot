LABELS = system("cat mem.grouped.csv | grep -v 'PID' | cut -d ',' -f1,2 | awk -F ':' '{printf(\"%s \", $NF); for (i=1; i<=NF-1; i++) {printf(\"%s\", $i); if (i<NF-1) printf \":\"} print \"\"}' | sort -t ' ' -k1,1n -k2,2n | awk '{print $2,$1}' | cut -d ',' -f2 | sed -e 's/ /:/' | uniq")
set datafile separator ","
set key autotitle columnhead
set key outside below height 2
set key horizontal maxcolumns 3
set xlabel "Time (ms)"
set ylabel "Memory (KB)"
set term eps enhanced color size 8,10
set output "output.eps"
plot for [i=1:words(LABELS)] sprintf("%s.fragment.csv", word(LABELS,i)) u 1:3 with linespoints pointinterval 100 title word(LABELS,i) noenhanced
