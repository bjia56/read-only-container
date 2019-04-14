LABELS = system("cat mem.grouped.csv | grep -v 'PID' | cut -d ',' -f1,2 | awk -F ':' '{printf(\"%s \", $NF); for (i=1; i<=NF-1; i++) {printf(\"%s\", $i); if (i<NF-1) printf \":\"} print \"\"}' | sort -t ' ' -k1,1n -k2,2n | awk '{print $2,$1}' | cut -d ',' -f2 | sed -e 's/ /:/' | uniq | awk '{if(system(\"[ -f \" $1 \".fragment.csv ]\") == 0) {print $1}}' | uniq")
set datafile separator ","
set key autotitle columnhead
set key outside below height 2
set key horizontal maxcolumns 3
set xlabel "Time (ms)"
set ylabel "Memory (KB)"
set title "Memory usage over time, by process:PID"
set term eps enhanced color size 8,8
set output "output.eps"
plot for [i=1:words(LABELS)] sprintf("%s.fragment.csv", word(LABELS,i)) u 1:3 with linespoints pointinterval 200 title word(LABELS,i) noenhanced
