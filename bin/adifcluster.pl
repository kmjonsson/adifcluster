#!/usr/bin/perl

use strict;
use warnings;

my $call = "ur0call";
my $host = "cluster.example.com";
my $port = 8000;
my $spotfile = "/var/www/adifcluster/spots.json";

use IO::Socket;

use Digest::MD5 qw(md5_hex);

use JSON;

use Encode qw(decode encode);

use FindBin;

use lib "$FindBin::Bin/lib";

use Prefix;
use LoTW;
use eQSL;
use Adif;
use ModeGroup;

Prefix::init("$FindBin::Bin/dat") || die;
LoTW::init("$FindBin::Bin/dat/lotw.txt") || die;
eQSL::init("$FindBin::Bin/dat/AGMemberList.txt") || die;

$|=1;

my $remote = IO::Socket::INET->new(
			Proto    => "tcp",
			PeerAddr => $host,
			PeerPort => $port,
		) or die "cannot connect to daytime port at localhost";

sleep(1);
print $remote "$call\r\n";
my @spots;
while ( <$remote> ) { 
	$_ = decode('ISO-8859-1',$_);
	s,[^\s[A-Z0-9\-\?\!\:\/]+,,gi;
	print;
	s,,,g;
	s,[\r\n]+,,g;
	if(/^DX de (\S+):\s+([\d\.]+)\s+(\S+)\s+(.*)\s(\d{4}Z)\s*(\S+|)$/) {
		my($de,$freq,$call,$comment,$time,$sq) = ($1,$2,$3,$4,$5,$6);
		$comment =~ s,\s+$,,;
		$comment =~ s,^\s+,,;
		printf("Call: %s @ %s [%s]{%s} (%s) de %s\n",
				$call,$freq,$time,$sq,$comment,$de);
		my $pfx = Prefix::findpfx($call);
		next unless defined $pfx;
		my $spot = {
			call    => $call,
			freq    => pprint_freq($freq),
			time    => $time,
			sq      => $sq,
			de      => $de,
			comment => $comment,
			prefix  => $pfx->{prefix},
			cqzone  => $pfx->{cqzone},
			name    => $pfx->{name},
			band    => freq2band($freq),
		};
		$spot->{id}	= md5_hex("$call,$freq,$time,$sq,$de,$comment");
		push @spots, $spot;
		if(scalar @spots > 120) {
			shift @spots;
		}
		open(my $out,">","$spotfile.new") || next;
		print $out to_json(\@spots,{ pretty => 0 });
		close($out) || next;
		rename("$spotfile.new", $spotfile);
	}
}

sub pprint_freq {
	my($freq) = @_;
	return $freq if($freq =~ s,(\d\d\d\d)$,.$1,);
	return $freq;
}

sub freq2band {
        my($f) = @_;
                $f /= 10000.0;
        return "0M" unless defined $f;
        return "0M" unless $f =~ /^[\d\.\-]+$/;
        if(int($f) == 1 || int($f) == 2) {
                return "160M";
        }
        if(int($f) == 3) {
                return "80M";
        }
        if(int($f) == 7) {
                return "40M";
        }
        if(int($f) == 10) {
                return "30M";
        }
        if(int($f) == 14) {
                return "20M";
        }
        if(int($f) == 18) {
                return "17M";
        }
        if(int($f) == 21) {
                return "15M";
        }
        if(int($f) == 24) {
                return "12M";
        }
        if(int($f) == 28 || int($f) == 29) {
                return "10M";
        }
        if(int($f) >= 50 && int($f) <= 52) {
                return "6M";
        }
        return "0M";
}
