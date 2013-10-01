#!/opt/local/bin/gnuplot

file       = "syp_bfot.dat"
start_date = "08/16/12"
end_date   = "09/25/13"

set title "Mean # Bug fixes Over Time, (+- Std Error)"
set xdata time
set timefmt "%m/%d/%y"
set yrange [0:50]
set xtics nomirror
set xtics rotate by -45
set rmargin 8
set grid ytics
set pointsize 1
set bars 3
set xrange [start_date:end_date]
set terminal svg enhanced mouse size 1366,768 fname 'Verdana' fsize 10
plot file using 1:2 pt 7 notitle