FILES = system("ls -1 *.fragment.csv")
LABEL = system("ls -1 *.fragment.csv | sed -e 's/.fragment.csv//'")
set datafile separator ","
set key autotitle columnhead
set term postscript enhanced color font 'Verdana' size 24,10
set output "output.ps"
set key outside
plot for [i=1:words(FILES)] word(FILES,i) u 1:3 with linespoints pointinterval 100 title word(LABEL,i) noenhanced
