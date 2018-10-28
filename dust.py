#!/usr/local/bin/python2.7
# -*- coding: UTF-8 -*-
# this code indented with actual 0x09 tabs

# This is a hacked up version of code from: https://gist.github.com/geoffwatts/b0b488b5a5257223ed53

import serial, time, datetime, struct, fileinput
import numpy as np
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

wx_dir = "/home/ghz/dust"

def write_out(file_name, data, mode):
	out_file_fd = open(file_name, mode)
	out_file_fd.write(data)
	out_file_fd.close()

def write_out_dat_stamp(ts, n_plate, data):
	# year directories should be created once a year from cron
	# that way we aren't unnecessarily checking for one every minute of every day for a year

	f_ts = ts[0:8]
	y_ts = ts[0:4]
	write_out(wx_dir+'/data/'+y_ts+'/'+n_plate+'.'+f_ts, data, 'a')

def graph(lx, ly, lfmt, ltitle, lylabel, lfname):
	plot_d = wx_dir+'/plots/'
	plt.figure(figsize=(20, 6), dpi=100)
	plt.grid(True)
	plt.plot_date(x = lx, y = ly, fmt = lfmt)
	plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m-%d\n%H:%M:%S'))
	plt.gca().xaxis.set_major_locator(mdates.HourLocator(interval=4))
	plt.minorticks_on()
	plt.gcf().autofmt_xdate()
	plt.title(ltitle)
	plt.xlabel("Date (UTC)")
	plt.ylabel(lylabel)
	ymin, ymax = plt.ylim()
	plt.twinx()
	plt.ylim(ymin, ymax)
	plt.ylabel(lylabel)
	plt.tight_layout()
	plt.savefig(plot_d+lfname)
	plt.close()

def plot(ts, n_plate):
	# default font can't do subscript ₂
	mpl.rc('font', family='DejaVu Sans')

	npoints = 2200 # ~48h

	d_date = ["0000", "0000", "0000", "0000"]
	d_year = ["0000", "0000", "0000", "0000"]

	td = datetime.datetime.strptime(ts, "%Y%m%d%H%M%S")

	for i in range(0, 4):
		d_date[i] = (td - datetime.timedelta(i)).strftime("%Y%m%d")
		d_year[i] = (td - datetime.timedelta(i)).strftime("%Y")

	dat_f0 = wx_dir+'/data/'+d_year[0]+'/'+n_plate+'.'+d_date[0]
	dat_f1 = wx_dir+'/data/'+d_year[1]+'/'+n_plate+'.'+d_date[1]
	# dat_f2 = wx_dir+'/data/'+d_year[2]+'/'+n_plate+'.'+d_date[2]
	# dat_f3 = wx_dir+'/data/'+d_year[3]+'/'+n_plate+'.'+d_date[3]

	plot_d = wx_dir+'/plots/'

	# dust_dat  = fileinput.input([dat_f3, dat_f2, dat_f1, dat_f0])
	dust_dat  = fileinput.input([dat_f1, dat_f0])
	date, pm25, pm10 = np.loadtxt(dust_dat, usecols=(0, 3, 7), unpack=True, converters={ 0: mdates.strpdate2num('%Y%m%d%H%M%S')})

	if date.size < npoints:
		npoints = date.size - 1

	f_pts  = date.size - npoints
	t_pts  = date.size

	# graph(date[f_pts : t_pts], pm25[f_pts : t_pts], "b-", "Particulate Matter", u"PM 2.5 (μg/m³)", "dust_pm25.png")
	# graph(date[f_pts : t_pts], pm10[f_pts : t_pts], "g-", "Particulate Matter", u"PM 10 (μg/m³)", "dust_pm10.png")
	graph(date, pm25, "b-", "Particulate Matter", u"PM 2.5 (μg/m³)", "dust_pm25.png")
	graph(date, pm10, "g-", "Particulate Matter", u"PM 10 (μg/m³)", "dust_pm10.png")

if __name__ == "__main__":

	dat_fname = 'dust.dat'

	ser = serial.Serial()
	ser.port = "/dev/ttyU0" # Set this to your serial port
	ser.baudrate = 9600

	ser.open()
	ser.flushInput()

	byte, lastbyte = "\x00", "\x00"

	time0 = time1 = time.time()
	pm_25_val = pm_10_val = count = 0

	while True:
		lastbyte = byte
		byte = ser.read(size=1)
    
		# We got a valid packet header
		if lastbyte == "\xAA" and byte == "\xC0":
			sentence = ser.read(size=8) # Read 8 more bytes

			# Decode the packet - little endian, 2 shorts for pm2.5 and pm10, 2 reserved bytes, checksum, message tail
			readings = struct.unpack('<hhxxcc',sentence)
        
			pm_25_val += readings[0]/10.0
			pm_10_val += readings[1]/10.0
			# ignoring the checksum and message tail

			count += 1
			time1 = time.time()
			if((time1 - time0) > 60):
				ts =  datetime.datetime.fromtimestamp(time1).strftime("%Y%m%d%H%M%S")
				pm_25 = pm_25_val / count
				pm_10 = pm_10_val / count
				dat_string = "%s\tPM 2.5: %3.2f μg/m³\tPM 10: %3.2f μg/m³\n" % (ts, pm_25, pm_10)
				write_out_dat_stamp(ts, dat_fname, dat_string)
				plot(ts, dat_fname)
				pm_25_val = pm_10_val = count = 0
				time0 = time1 = time.time()
