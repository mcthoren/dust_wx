set term pngcairo size 2000, 512 font ",10"
set title "Average Daily Dust Levels"
set y2tics
set mytics
set key outside below
set xdata time
set timefmt "%Y%m%d"
set xlabel "Time (UTC)" offset 0.0, -1.6
set format x "%F"
set grid
set xtics auto rotate by 30 offset -6.8, -2.2
set mxtics 
set grid mxtics
set xrange ["20181211" < * :]

dat_f="~/dust/data/dust.day.avg"

set ylabel "PM_{2.5} (µg/m³)"
set y2label "PM_{2.5} (µg/m³)"
# set style fill solid 0.50 border lt -1
set style fill solid 0.50 noborder
set output "~/dust/plots/pm_2.5_day_avgs.png"
plot dat_f using 1:6 t 'PM_{2.5} (µg/m³)' with boxes linecolor rgb "#0000ff"

set ylabel "PM_{10} (µg/m³)"
set y2label "PM_{10} (µg/m³)"
set output "~/dust/plots/pm_10_day_avgs.png"
plot dat_f using 1:12 t 'PM_{10} (µg/m³)' with boxes linecolor rgb "#00aa00"
