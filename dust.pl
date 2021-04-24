#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);
use Encode qw(encode decode);
use POSIX qw(strftime);
use Device::SerialPort;

sub usage() {
	print "usage: $0 serial_port\n";
	exit;
}

my $data_dir_t = "/import/home/ghz/repos/dust_wx/data";

sub write_out_dat($$) {
	my ($pm25, $pm10) = @_;
	my $f_tplate = "dust.dat";
	my $date_y = strftime("%Y", gmtime);
	my $tdate = strftime("%Y%m%d", gmtime);
	my $ts = strftime("%FT%T%Z", gmtime);
	my $data_dir = "$data_dir_t/$date_y";

	unless ( -d $data_dir) {
		mkdir $data_dir or die "couldn't make $data_dir";
	}

	my $dat_f = "$data_dir/$f_tplate.$tdate";
	open(OUT, ">>", $dat_f) or die "omg! can't open output file: $dat_f";
	printf OUT "%s\tPM 2.5: %.2f µ/m³\tPM 10: %.2f µ/m³\n", $ts, $pm25 / 10.0, $pm10 / 10.0;
	close OUT;
}

unless ($#ARGV == 0) {
	usage();
}

@ARGV = map { decode("UTF-8", $_) } @ARGV;
my $read_f = $ARGV[0];

unless (-c  $read_f) {
	usage;
}

unless ( -d $data_dir_t) {
	print "$data_dir_t doesn't exit\n";
	mkdir $data_dir_t or die "couldn't make $data_dir_t";
}

my $port = Device::SerialPort->new($read_f) || die "serial port open failed";

# 9600n81
$port->baudrate(9600);
$port->parity("none");
$port->databits(8);
$port->stopbits(1);

$port->purge_all;
# $port->purge_rx;
# $port->purge_tx;

# from the docs: https://metacpan.org/pod/Device::SerialPort
# keeps my load astoundingly lower
$port->read_const_time(100);	# const time for read (milliseconds)
$port->read_char_time(5);	# avg time between read char

my $debug = 0;
my ($itr, $pm25_t, $pm10_t) = (0, 0, 0);
my($b0, $ub, $cnt) = (hex("0xde"), hex("0xad"), hex("0xbe"));

while (1) {
	($cnt, $b0) = $port->read(1);
	$ub = unpack('C', $b0);	
	printf "ub: 0x%02x\t", $ub if $ub && $debug;
	printf "cnt: %d\n", $cnt if $cnt && $debug;
	if ($ub and $ub == hex("0xaa")) {
		($cnt, $b0) = $port->read(1);
		$ub = unpack('C', $b0);	
		if ($ub == hex("0xc0")) {
			($cnt, $b0) = $port->read(8);
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

			$pm25_t += $pm25;
			$pm10_t += $pm10;
			$itr++;
			if ($itr >= 60) {
				write_out_dat($pm25_t/$itr/10.0, $pm10_t/$itr/10.0);
				$pm25_t = 0;
				$pm10_t = 0;
				$itr = 0;
			}
		}
	}
}
