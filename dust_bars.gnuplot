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
set xtics out
set ytics out
set xrange [:] noextend
set format y "%.1f"
set format y2 "%.1f"

dat_f="~/dust/data/dust.day.avg"
dat_f_30="~/dust/data/dust.day.avg.30"

set ylabel "PM_{2.5} (µg/m³)"
set y2label "PM_{2.5} (µg/m³)"
set style fill solid 0.50 noborder
set output "~/dust/plots/pm_2.5_day_avgs.png"
plot dat_f using 1:6 t 'PM_{2.5} (µg/m³)' with boxes linecolor rgb "#0000ff", \
5 title 'WHO Annual PM_{2.5} Guidline: 5 µg/m³' with lines lw 1 linecolor rgb "#bb0000", \
15 title 'WHO 24-Hour PM_{2.5} Guidline: 15 µg/m³' with lines lw 1 linecolor rgb "#bb00ff"

set title "Average Daily Dust Levels for the Last 30 Days"
set output "~/dust/plots/pm_2.5_day_avgs.30.png"
plot dat_f_30 using 1:6 t 'PM_{2.5} (µg/m³)' with boxes linecolor rgb "#0000ff", \
5 title 'WHO Annual PM_{2.5} Guidline: 5 µg/m³' with lines lw 1 linecolor rgb "#c00000", \
15 title 'WHO 24-Hour PM_{2.5} Guidline: 15 µg/m³' with lines lw 1 linecolor rgb "#bb00ff"

set title "Average Daily Dust Levels"
set ylabel "PM_{10} (µg/m³)"
set y2label "PM_{10} (µg/m³)"
set output "~/dust/plots/pm_10_day_avgs.png"
plot dat_f using 1:12 t 'PM_{10} (µg/m³)' with boxes linecolor rgb "#00aa00", \
15 title 'WHO Annual PM_{10} Guidline: 15 µg/m³' with lines lw 1 linecolor rgb "#c00000", \
45 title 'WHO 24-Hour PM_{10} Guidline: 45 µg/m³' with lines lw 1 linecolor rgb "#bb00ff"

set title "Average Daily Dust Levels for the Last 30 Days"
set output "~/dust/plots/pm_10_day_avgs.30.png"
plot dat_f_30 using 1:12 t 'PM_{10} (µg/m³)' with boxes linecolor rgb "#00aa00", \
15 title 'WHO Annual PM_{10} Guidline: 15 µg/m³' with lines lw 1 linecolor rgb "#c00000", \
45 title 'WHO 24-Hour PM_{10} Guidline: 45 µg/m³' with lines lw 1 linecolor rgb "#bb00ff"
