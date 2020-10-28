set term pngcairo size 2000, 512 font ",10"
set title "Average Daily Dust Levels"
set y2tics
set key outside below
set xdata time
set timefmt "%Y%m%d"
set xlabel "Time (UTC)" offset 0.0, -1.6
set format x "%F"
set grid
set ylabel "PM (ug/m^3)"
set y2label "PM (ug/m^3)"
set xtics auto rotate by 30 offset -6.8, -2.2
set mxtics 
set grid mxtics

dat_f="~/dust/data/dust.day.avg"

set output "~/dust/plots/dust_day_avgs.png"
plot dat_f using 1:5 t 'PM 2.5 (ug/m^3)' with boxes linecolor rgb "#0000ff", \
dat_f using 1:11 t 'PM 10 (ug/m^3)' with boxes linecolor rgb "#00ff00"
