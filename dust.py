#!/usr/local/bin/python2.7
# -*- coding: UTF-8 -*-
# this code indented with actual 0x09 tabs

# This is a hacked up version of code from: https://gist.github.com/geoffwatts/b0b488b5a5257223ed53

import serial, time, datetime, struct
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

if __name__ == "__main__":

	dat_fname = 'dust.dat'

	ser = serial.Serial()
	ser.port = "/dev/ttyU0" # Set this to your serial port
	ser.baudrate = 9600

	ser.open()
	ser.flushInput()

	byte, lastbyte = "\x00", "\x00"

	while True:
		lastbyte = byte
		byte = ser.read(size=1)
    
		# We got a valid packet header
		if lastbyte == "\xAA" and byte == "\xC0":
			sentence = ser.read(size=8) # Read 8 more bytes
			readings = struct.unpack('<hhxxcc',sentence) # Decode the packet - big endian, 2 shorts for pm2.5 and pm10, 2 reserved bytes, checksum, message tail
        
			pm_25 = readings[0]/10.0
			pm_10 = readings[1]/10.0
			# ignoring the checksum and message tail
        
			ts =  datetime.datetime.fromtimestamp(time.time()).strftime("%Y%m%d%H%M%S")
			dat_string "%s\tPM 2.5: %3.3f μg/m³\tPM 10: %3.3f μg/m³" % (ts, pm_25, pm10)
			write_out_dat_stamp(ts, dat_fname, dat_string)
