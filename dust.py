#!/usr/bin/python3
# -*- coding: UTF-8 -*-
# this code indented with actual 0x09 tabs

# This is a hacked up version of code from: https://gist.github.com/geoffwatts/b0b488b5a5257223ed53

import os, sys, serial, time, struct

hostname = os.uname()[1]

home_dir='/home/ghz'

if hostname == 'keen':
	home_dir = '/import/home/ghz'

sys.path.append(home_dir+'/repos/wxlib')
import wxlib as wx

wx_dir = home_dir+'/dust'
plot_d = wx_dir+'/plots/'

def gen_index(pm25, pm10):
	plate = wx_dir+"/dust_wx_index.html.template"
	plate_fd = open(plate, 'r')
	plate_dat = plate_fd.read()
	plate_fd.close()

	ts = time.strftime("%FT%TZ", time.gmtime())

	plate_dat = plate_dat.replace("TTTPM25", str("%.2f" % pm25))
	plate_dat = plate_dat.replace("TTTPM10", str("%.2f" % pm10))
	plate_dat = plate_dat.replace("DATE", ts)

	wx.write_out(wx_dir+'/plots/dust_wx.html', plate_dat, 'w')

if __name__ == "__main__":

	dat_fname = 'dust.dat'
	wx.proof_dir(plot_d)

	ser = serial.Serial()
	# ser.port = "/dev/ttyU0"
	ser.port = "/dev/ttyUSB0"
	ser.baudrate = 9600

	ser.open()
	ser.flushInput()

	byte, lastbyte = b"\x00", b"\x00"

	debug = 1
	time0 = time1 = time.time()
	pm_25_val = pm_10_val = count = 0

	if debug:
		print("entering loop", flush=True)

	while True:
		lastbyte = byte
		byte = ser.read(size=1)
    
		if debug:
			print("0", end="", flush=True)

		# We got a valid packet header
		if lastbyte == b"\xAA" and byte == b"\xC0":
			sentence = ser.read(size=8) # Read 8 more bytes

			if debug:
				print("1", end="", flush=True)

			check = b"\x00\x00\x00\x00\x00\x00\x00\x00"
			check = struct.unpack('<cccccccc', sentence)

			if debug:
				print("2", end="", flush=True)

			# check tail byte, should also help eliminate short reads
			if check[7] != b"\xAB":
				print("tail byte not 0xAB", flush=True)
				continue

			if debug:
				print("3", end="", flush=True)

			# if it worked move on to checksum
			b = bytearray(sentence[0:7])
			if b[6] != (sum(b[0:6]) % 256):
				print("checksum failed", flush=True)
				continue

			if debug:
				print("4", end="", flush=True)

			# Decode the packet - little endian, 2 shorts for pm2.5 and pm10, 2 ID bytes, checksum, message tail
			readings = struct.unpack('<hhxxcc',sentence)
        
			pm_25_val += readings[0]
			pm_10_val += readings[1]

			if debug:
				print(".", end="", flush=True)

			count += 1
			time1 = time.time()
			if((time1 - time0) > 60):
				ts = time.strftime("%FT%T%Z", time.gmtime(float(time1)))
				tsf = time.strftime("%Y%m%d%H%M%S", time.gmtime(float(time1)))
				pm_25 = pm_25_val / count / 10.0
				pm_10 = pm_10_val / count / 10.0
				dat_string = "%s\tPM 2.5: %.2f μg/m³\tPM 10: %.2f μg/m³\n" % (ts, pm_25, pm_10)
				wx.write_out_dat_stamp(tsf, dat_fname, dat_string, wx_dir)

				if debug:
					print("\n" + dat_string, end="", flush=True)

				if hostname == 'elf':
					gen_index(pm_25, pm_10)

				pm_25_val = pm_10_val = count = 0
				time0 = time1 = time.time()
