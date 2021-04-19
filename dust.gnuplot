set title "Particulate matter"
set xtics 7200 rotate by 30 offset -5.7, -2.2
set ytics
set mytics
set y2tics
set key outside below
set xlabel "Time (UTC)" offset 0.0, -1.6
set xdata time;
set format x "%F\n%TZ"
set timefmt "%Y-%m-%dT%H:%M:%S"
set grid xtics
set grid y2tics
set term pngcairo size 1900, 512 font ",10"

set format y "%.1f"
set format y2 "%.1f"

dat_f="~/repos/dust_wx/data/dust.dat.2-3_day"

set ylabel "PM_{2.5} (µg/m³)"
set y2label "PM_{2.5} (µg/m³)"
set output "~/repos/dust_wx/plots/pm_25.png"
plot dat_f using 1:3 title 'Particulate Matter' with lines lw 2 linecolor rgb "#0000dd"

set ylabel "PM_{10} (µg/m³)"
set y2label "PM_{10} (µg/m³)"
set output "~/repos/dust_wx/plots/pm_10.png"
plot dat_f using 1:6 title 'Particulate Matter' with lines lw 2 linecolor rgb "#00dd00"