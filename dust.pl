#!/usr/bin/perl -T

use strict;
use warnings;
use Fcntl;
use POSIX qw(strftime);

sub usage() {
	print "usage: $0 serial_port\n";
	exit;
}

my $read_f = $ARGV[0];

unless (-c  $read_f) {
	usage;
}

open(IN, "<:raw", $read_f) or die "omg! can't open input file: $read_f";
# sysopen(IN, $read_f, O_RDONLY) or die "omg! can't open input file: $read_f";
# IN->flush();

my $debug = 0;
my($b0, $ub) = (0, 0);
while (1) {
	read(IN, $b0, 1);
	$ub = unpack('C', $b0);	
	print "$ub\n" if $ub && $debug;
	if ($ub and $ub == hex("0xaa")) {
		read(IN, $b0, 1);
		$ub = unpack('C', $b0);	
		if ($ub == hex("0xc0")) {
			read(IN, $b0, 8);
			my $ts = strftime("%FT%T%Z", gmtime);
			my ($c0, $c1, $c2, $c3, $c4, $c5, $c6, $c7) = unpack('CCCCCCCC', $b0);	
			if ($c7 != hex("0xab")) {
				printf "tail byte fail! 0x%02x != 0xab\n", $c7;
				next;
			}

			my $csum = $c0 + $c1 + $c2 + $c3 + $c4 + $c5;
			if ($csum % 256 != $c6){
				printf "csum mod 256: 0x%02x, checksum: 0x%02x\n", $csum % 256, $c6;
				next;
			}

			my($pm25, $pm10, $b1, $b2, $b3, $b4) = unpack('vvCCCC', $b0);	
			printf "%.2f, %.2f, 0x%02x, 0x%02x, 0x%02x, 0x%02x, 0x%02x\n",
				$pm25 / 10.0, $pm10 / 10.0, $b1, $b2, $b3, $b4, $csum % 256 if $debug == 1;
			printf "%s\tPM_2.5: %.2f µ/m³\tPM_10: %.2f µ/m³\n", $ts, $pm25 / 10.0, $pm10 / 10.0;
		}
	}
}
