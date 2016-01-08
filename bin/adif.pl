#!/usr/bin/perl 

use strict;
use warnings;

use JSON;
use Data::Dumper;

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

my %data;
my $adif = Adif::parseFile(@ARGV);

for my $q (@{$adif->{qsos}}) {
	my $pfx = Prefix::findpfx($q->{call});

	my $r = {
		'freq'            => $q->{freq},
		'mode'            => $q->{mode},
		'qsl'             => $q->{qsl_rcvd} // "N",
		'qsl_lotw'        => $q->{lotw_qsl_rcvd} // "N",
		'qsl_eqsl'        => $q->{eqsl_qsl_rcvd} // "N",
	};

	$r->{qsl}      = ($r->{qsl} eq 'Y'?'yes':'no');
	$r->{qsl_lotw} = ($r->{qsl_lotw} eq 'Y'?'yes':'no');
	$r->{qsl_eqsl} = ($r->{qsl_eqsl} eq 'Y'?'yes':'no');

	$r->{modegroup} = ModeGroup::convert($q->{mode});
	$r->{band}      = "\U$q->{band}" // freq2band($q->{freq});
	$r->{prefix}    = $pfx->{prefix} // "";
	$r->{cqzone}    = $pfx->{cqzone} // -1;
	$r->{itureg}    = $pfx->{itureg} // -1;
	$r->{continent} = $pfx->{continent} // "";
	$r->{state} = $pfx->{state} // "";

	$data{$r->{prefix}} //= {};
	$data{$r->{prefix}}->{$r->{band}} //= {};
	$data{$r->{prefix}}->{$r->{band}}->{qsl} = 'Y' if $r->{qsl} eq 'yes';
	$data{$r->{prefix}}->{$r->{band}}->{qsl_lotw} = 'Y' if $r->{qsl_lotw} eq 'yes';
	$data{$r->{prefix}}->{$r->{band}}->{qsl_eqsl} = 'Y' if $r->{qsl_eqsl} eq 'yes';
	$data{$r->{prefix}}->{$r->{band} . "-" . $r->{modegroup}} //= {};
	$data{$r->{prefix}}->{$r->{band} . "-" . $r->{modegroup}}->{qsl} = 'Y' if $r->{qsl} eq 'yes';
	$data{$r->{prefix}}->{$r->{band} . "-" . $r->{modegroup}}->{qsl_lotw} = 'Y' if $r->{qsl_lotw} eq 'yes';
	$data{$r->{prefix}}->{$r->{band} . "-" . $r->{modegroup}}->{qsl_eqsl} = 'Y' if $r->{qsl_eqsl} eq 'yes';
}

print to_json(\%data,{pretty => 1, canonical => 1});

sub freq2band {
        my($f) = @_;
		$f /= 1000.0;
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


sub band2freq {
        my($f) = @_;
        if($f eq '6M') {
                return 50;
        }
        if($f eq '10M') {
                return 28;
        }
        if($f eq '12M') {
                return 24;
        }
        if($f eq '15M') {
                return 21;
        }
        if($f eq '17M') {
                return 18;
        }
        if($f eq '20M') {
                return 14;
        }
        if($f eq '30M') {
                return 10;
        }
        if($f eq '40M') {
                return 7;
        }
        if($f eq '80M') {
                return 3.5;
        }
        if($f eq '160M') {
                return 1.8;
        }
        return 0;
}
