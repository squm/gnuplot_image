#!/gnuplot

reset

set nokey
set xlabel 'Quality'
set ylabel 'File Size'

set term png size 800,600
set output 'quality.png'

plot \
'quality.txt' using 1:2 with lines, \
'quality.txt' using 1:3 with lines, \
'quality.txt' using 1:4 with lines, \
'quality.txt' using 1:5 with lines, \
'quality.txt' using 1:6 with lines, \
1/0 notitle
