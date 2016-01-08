
package Contest;

my %config = (
	'SAC-SSB'		=>	{ parseQSO => \&sac_ssb,
							info => { len => '24' }
						},
	'SAC-CW'		=>	{ parseQSO => \&cq_ww,
							info => { len => '24' }
						},
	'CQ-WW-SSB'		=>	{ parseQSO => \&cq_ww,
							info => { len => '48' }
						},
	'CQ-WW-CW'		=>	{ parseQSO => \&cq_ww,
							info => { len => '48' }
						},
	'CQ-WW-RTTY'	=>	{ parseQSO => \&cq_ww_rtty,
							info => { len => '48' }
						},
	'CQ-WPX-SSB'	=>	{ parseQSO => \&cq_ww,
							info => { len => '48' }
						},
	'CQ-WPX-CW'		=>	{ parseQSO => \&cq_ww,
							info => { len => '48' }
						},
	'CQ-WPX-RTTY'	=>	{ parseQSO => \&cq_ww,
							info => { len => '48' }
						},
	'RDXC'			=>	{ parseQSO => \&rdxc,
							info => { len => '24' }
						},
);

sub info {
	my($contest) = @_;
	if(!defined $config{$contest}) {
		warn "unknwon contest: $contest\n";
		return undef;
	}
	return $config{$contest}->{info};
}

sub parse {
	my($contest,$qso) = @_;
	my $r;
	if(!defined $config{$contest}) {
		warn "unknwon contest: $contest\n";
		return undef;
	}
	$r = &{$config{$contest}->{parseQSO}}($qso);
	if(defined $r) {
		$r->{transmitter} //= 0;
		#foreach my $k (qw/freq srst sexch rrst rexch mycall/) {
		foreach my $k (qw/mycall/) {
			delete $r->{$k};
		}
	}
	return $r;
}

# CQ-WW-RTYY
# http://www.cqwwrtty.com/logs.htm
#                                --------info sent------- -------info rcvd--------
#  QSO: freq  mo date       time call          rst exch   call          rst exch   t
#  QSO: ***** ** yyyy-mm-dd nnnn ************* nnn ****** ************* nnn ****** n
#  QSO:  3595 RY 1999-03-06 0711 HC8N          599 13 DX  W1AW          599 05 CT  0
#  000000000111111111122222222223333333333444444444455555555556666666666777777777788
#  123456789012345678901234567890123456789012345678901234567890123456789012345678901

sub cq_ww_rtty {
	my($qso) = @_;
	if($qso =~ /^\s*(\d+)\s+(RY)\s+(\d{4}-\d\d-\d\d)\s+(\d{4})\s+(\S+)\s+(\d{3}\s\S+)\s+(\S+)\s+(\S+)\s+(\d{3}\s\S+)\s+(\S+)(\s+\d|)\s*$/) {
		my($freq,$mode,$date,$time,$mycall,$srst,$sexch,$call,$rrst,$rexch,$transmitter) = ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11);
		my $r = {
			'freq'		  => $freq,
			'band'		  => freq2band($freq),
			'mode'		  => $mode,
			'date'  	  => $date,
			'time'		  => fixTime($time),
			'mycall'	  => $mycall,
			'srst'		  => $srst,
			'sexch'	      => $sexch,
			'call'		  => $call,
			'rrst'		  => $rrst,
			'rexch'       => $rexch,
			'transmitter' => $transmitter,
		};
		return strip($r);
	}
	return undef;
}
# RDXC
#
#                            --------info sent------- -------info rcvd--------
#   QSO: freq  mo date       time call          rst exch   call          rst exch
#   QSO: ***** ** yyyy-mm-dd nnnn ************* nnn ****** ************* nnn ******
#   QSO: 21010 CW 2004-03-20 1200 VE3DZ         599 001    RL3A          599 MA
#   0000000001111111111222222222233333333334444444444555555555566666666667777777777
#   1234567890123456789012345678901234567890123456789012345678901234567890123456789

sub rdxc {
	my($qso) = @_;
	if($qso =~ /^\s*(\d+)\s+(PH|CW)\s+(\d{4}-\d\d-\d\d)\s+(\d{4})\s+(\S+)\s+(\d{2,3})\s+(\S+)\s+(\S+)\s+(\d{2,3})\s+(\S+)(\s+\d|)\s*$/) {
		my($freq,$mode,$date,$time,$mycall,$srst,$sexch,$call,$rrst,$rexch,$transmitter) = ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11);
		my $r = {
			'freq'		  => $freq,
			'band'		  => freq2band($freq),
			'mode'		  => $mode,
			'date'  	  => $date,
			'time'		  => fixTime($time),
			'mycall'	  => $mycall,
			'srst'		  => $srst,
			'sexch'	      => $sexch,
			'call'		  => $call,
			'rrst'		  => $rrst,
			'rexch'       => $rexch,
			'transmitter' => $transmitter,
		};
		return strip($r);
	}
	return undef;
}

# CQ-WW
# http://www.cqww.com/cabrillo.htm
#
#                                --------info sent------- -------info rcvd--------
#  QSO: freq  mo date       time call          rst exch   call          rst exch   t
#  QSO: ***** ** yyyy-mm-dd nnnn ************* nnn ****** ************* nnn ****** n
#  QSO:  3799 PH 2000-11-26 0711 N6TW          59  03     JT1Z          59  23     0
#
#  000000000111111111122222222223333333333444444444455555555556666666666777777777788
#  123456789012345678901234567890123456789012345678901234567890123456789012345678901
#
# SAC-CW
#  --------info sent------- -------info rcvd--------
#  QSO: freq  mo date       time call          rst exch   call          rst exch   t
#  QSO: ***** ** yyyy-mm-dd nnnn ************* nnn ****** ************* nnn ****** *
#  QSO: 14000 CW 2009-09-19 1748 7S3A          599      1 4K6GF         599    116 0
#  000000000111111111122222222223333333333444444444455555555556666666666777777777788
#  123456789012345678901234567890123456789012345678901234567890123456789012345678901
#
sub cq_ww {
	my($qso) = @_;
	if($qso =~ /^\s*(\d+)\s+(RY|PH|CW)\s+(\d{4}-\d\d-\d\d)\s+(\d{4})\s+(\S+)\s+(\d{2,3})\s+(\d+)\s+(\S+)\s+(\d{2,3})\s+(\d+)(\s+\d|)\s*$/) {
		my($freq,$mode,$date,$time,$mycall,$srst,$sexch,$call,$rrst,$rexch,$transmitter) = ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11);
		my $r = {
			'freq'		  => $freq,
			'band'		  => freq2band($freq),
			'mode'		  => $mode,
			'date'  	  => $date,
			'time'		  => fixTime($time),
			'mycall'	  => $mycall,
			'srst'		  => $srst,
			'sexch'	      => $sexch,
			'call'		  => $call,
			'rrst'		  => $rrst,
			'rexch'       => $rexch,
			'transmitter' => $transmitter,
		};
		return strip($r);
	}
	return undef;
}

#
# SAC-SSB
#  --------info sent------- -------info rcvd--------
#  QSO: freq  mo date       time call          rst exch   call          rst exch   t
#  QSO: ***** ** yyyy-mm-dd nnnn ************* nnn ****** ************* nnn ****** *
#  QSO: 14000 CW 2009-09-19 1748 7S3A          599      1 4K6GF         599    116 0
#  000000000111111111122222222223333333333444444444455555555556666666666777777777788
#  123456789012345678901234567890123456789012345678901234567890123456789012345678901
#
sub sac_ssb {
	my($qso) = @_;
	if($qso =~ /^\s*(\d+)\s+(PH|LS|US)\s+(\d{4}-\d\d-\d\d)\s+(\d{4})\s+(\S+)\s+(\d{2,3})\s+(\d+)\s+(\S+)\s+(\d{2,3})\s+(\d+)(\s+\d|)\s*$/) {
		my($freq,$mode,$date,$time,$mycall,$srst,$sexch,$call,$rrst,$rexch,$transmitter) = ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11);
		my $r = {
			'freq'		  => $freq,
			'band'		  => freq2band($freq),
			'mode'		  => 'PH',
			'date'  	  => $date,
			'time'		  => fixTime($time),
			'mycall'	  => $mycall,
			'srst'		  => $srst,
			'sexch'	      => $sexch,
			'call'		  => $call,
			'rrst'		  => $rrst,
			'rexch'       => $rexch,
			'transmitter' => $transmitter,
		};
		return strip($r);
	}
	return undef;
}

sub strip {
	my($r) = @_;
	foreach my $k (keys %$r) {
		$r->{$k} =~ s,^\s+,,;
		$r->{$k} =~ s,\s+$,,;
	}
	return $r;
}

sub fixTime {
	my($t) = @_;
	return "$1:$2:00" if $t =~ /^(\d\d)(\d\d)$/;
	return $t;
}

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

1;
