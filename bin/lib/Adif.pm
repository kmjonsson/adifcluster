
package Adif;

use Time::Local;

sub newAdif {
	return { header => undef, qsos   => [] };
}

sub parseFile {
	my($file) = @_;
	open(IN,"<$file") || return undef;
	my $str = join(" ",<IN>);
	close(IN);
	return parseStr($str);
}

sub parseStr {
	my($in) = @_;
	$in =~ s,[\r\n]+,\\n,gm;
	my %result = ( header => undef, qsos   => [] );
	if($in =~ m,^(.*)<EOH>,mi) {
		$in =~ s,^(.*)<EOH>,,mi;
		$result{header} = $1;
	}
	my(@qsos) = split(/<EOR>/i,$in);
	foreach my $str (@qsos) {
		my $curr = undef;
		while(length($str)) {
			if($str =~ m,^(.*?)<([^>]+)>,i) {
				$str =~ s,^(.*?)<([^>]+)>,,i;
				my($key,$len,$type) = ($2,0,"");
				if($key =~ /^(.*):(\d+):(.*)$/) { $key = $1; $len = $2; $type = $3; }
				if($key =~ /^(.*):(\d+)$/) { $key = $1; $len = $2; }
				my $data = substr($str,0,$len,'');
				$curr = {} unless defined $curr;
				$curr->{"\L$key"} = $data;
				next;
			} 
			last;
		}
		$curr->{'band'} = freq2band($curr->{'freq'}) unless defined $curr->{'band'};
		$curr->{time_on} .= "00" if(defined $curr->{time_on} && length($curr->{time_on}) == 4);
		push @{$result{'qsos'}},$curr if defined $curr && defined $curr->{call};
	}
	return \%result;
}

sub merge {
	my(@logs) = @_;
	return undef unless scalar @logs;
	return undef unless defined $logs[0];
	my %worked;
	my @qsos;
	foreach my $log (@logs) {
		foreach my $e (@{$log->{qsos}}) {
			$ustr = sprintf("%s:%s:%s",$e->{qso_date},$e->{time_on},$e->{call});
			$ustr = "\U$ustr";
			if(defined $worked{$ustr}) {
				foreach my $k (keys %{$e}) {
					$worked{$ustr}->{$k} = $e->{$k};
				}
			} else {
				$worked{$ustr} = $e;
				push @qsos,$e;
			}
		}
	}
	return {
			'header' => $logs[0]->{header},
			'qsos'   => [sort { $a->{qso_date} . $a->{time_on} <=> $b->{qso_date} . $b->{time_on} } @qsos],
	};
}

sub _generateTimeRange {
	my($date,$time) = @_;
	if("$date:$time" !~ /^(\d{4})(\d{2})(\d{2}):(\d{2})(\d{2})(\d{2})/) {
		return "$date:$time";
	}
	my($year,$mon,$mday,$hour,$min, $sec) = ($1-1900,$2-1,$3,$4,$5, 0); 
	my $t = timegm( $sec, $min, $hour, $mday, $mon, $year );
	my @res;
	foreach my $d ( 0, -60 .. 60 ) {
		my $x = $t + $d * 60;
		my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($x);
		push @res, sprintf("%04d%02d%02d:%02d%02d00",$year+1900,$mon+1,$mday,$hour,$min);
	}
	return @res;
}

sub update {
	my(@logs) = @_;
	return undef unless scalar @logs;
	return undef unless defined $logs[0];
	my %worked;
	my @qsos;
	my $first=1;
	foreach my $log (@logs) {
		foreach my $e (@{$log->{qsos}}) {
			my $b = $e->{band} // freq2band($e->{freq}) // "0M";
			my($base,@gtr) = _generateTimeRange($e->{qso_date},$e->{time_on});
			my $bstr = sprintf("%s:%s:%s:%s",$base,$e->{call},$e->{band},$e->{mode});
			my $found = 0;
			@gtr = ($base) if $first;
			foreach my $dt (@gtr) {
				my $ustr = sprintf("%s:%s:%s:%s",$dt,$e->{call},$e->{band},$e->{mode});
				$ustr = "\U$ustr";
				if(defined $worked{$ustr}) {
					foreach my $k (keys %{$e}) {
						next if $k eq 'time_on';
						next if $k eq 'qso_date';
						$worked{$ustr}->{$k} = $e->{$k};
					}
					$found = 1;
				}
			}
			if(!$found && $first) {
				$worked{$bstr} = $e;
				push @qsos,$e;
			}
		}
		$first=0;
	}
	return {
			'header' => $logs[0]->{header},
			'qsos'   => [sort { $a->{qso_date} . $a->{time_on} <=> $b->{qso_date} . $b->{time_on} } @qsos],
	};
}

sub generateAdif {
	my($log) = @_;
	my $output = $log->{header} . "\n<EOH>\n\n";
	$output =~ s,\\n,\n,g;
	foreach my $e (@{$log->{qsos}}) {
		foreach my $key (sort keys %$e) {
			next unless defined $e->{$key};
			$output .= sprintf("<%s:%d>%s",$key,length($e->{$key}),$e->{$key});
		}
		$output .= "<EOR>\n";
	}
	return $output;
}


sub freq2band {
        my($f) = @_;
		return undef unless defined $f;
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
