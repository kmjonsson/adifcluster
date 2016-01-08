
package Prefix;

use Cty;

use greatc;

my %ctys;

sub init {
	my($base) = @_;
	$ctys{'main'} = Cty::fixCty(Cty::parseFile($base . '/cty.dat'));
	for my $c (qw/AF AS BY EU NA SA VK/) {
		$ctys{$c} = Cty::fixCty(Cty::parseFile($base . "/$c\_cty.dat"));
	}
	return 1;
}

sub findpfx {
	my($call) = @_;
	my(%pfx);
	if(defined $ctys{'main'}->{calls}->{$call}) {
		%pfx = %{$ctys{'main'}->{calls}->{$call}};
		$pfx{'sname'} = '';
		return \%pfx;
	}
	my $c = substr($call,0,$ctys{'main'}->{maxLength});
	while(length($c) > 0) {
		if(defined $ctys{'main'}->{prefixes}->{$c} && ! $ctys{'main'}->{prefixes}->{$c}->{nodxcc}) {
			%pfx = %{$ctys{'main'}->{prefixes}->{$c}};
			if(defined $ctys{'main'}->{prefixes}->{$c}->{special}) {
				foreach my $x (@{$ctys{'main'}->{prefixes}->{$c}->{special}}) {
					my $r = $x->{regexp};
					%pfx = %{$ctys{'main'}->{prefixes}->{$x->{is}}} if($call =~ /$r/);
				}
			}
			last;
		}
		$c =~ s,.$,,;
	}
	if(!defined $pfx{'prefix'}) {
		my $c = substr($call,0,$ctys{'main'}->{maxLength});
		while(length($c) > 0) {
			if(defined $ctys{'main'}->{prefixes}->{$c}) {
				%pfx = %{$ctys{'main'}->{prefixes}->{$c}};
				last;
			}
			$c =~ s,.$,,;
		}
	}
	return undef unless defined $pfx{'prefix'};
	my($p,$l);
	if($pfx{'continent'} eq 'AF'){ $p = $ctys{'AF'}->{prefixes}; $l = $ctys{'AF'}->{maxLength}; }
	if($pfx{'continent'} eq 'AS'){ $p = $ctys{'AS'}->{prefixes}; $l = $ctys{'AS'}->{maxLength}; }
	if($pfx{'continent'} eq 'EU'){ $p = $ctys{'EU'}->{prefixes}; $l = $ctys{'EU'}->{maxLength}; }
	if($pfx{'continent'} eq 'NA'){ $p = $ctys{'NA'}->{prefixes}; $l = $ctys{'NA'}->{maxLength}; }
	if($pfx{'continent'} eq 'SA'){ $p = $ctys{'SA'}->{prefixes}; $l = $ctys{'SA'}->{maxLength}; }
	if($pfx{'prefix'} eq 'BY')   { $p = $ctys{'BY'}->{prefixes}; $l = $ctys{'BY'}->{maxLength}; }
	if($pfx{'prefix'} eq 'VK')   { $p = $ctys{'VK'}->{prefixes}; $l = $ctys{'VK'}->{maxLength}; }

	if(!defined $p) {
		$pfx{'sname'} = '';
		return \%pfx;
	}
	$c = substr($call,0,$l);
	my(%spfx);
	while(length($c) > 0) {
		if(defined $p->{$c} && ! $p->{$c}->{nodxcc}) {
			%spfx = %{$p->{$c}};
			last;
		}
		$c =~ s,.$,,;
	}
	if(!defined $spfx{'prefix'}) {
		$pfx{'sname'} = '';
		return \%pfx;
	}
	my(%ret) = %spfx;
	$ret{'pfx'} = \%pfx;
	$ret{'spfx'} = \%spfx;
	$ret{'sname'} = $ret{'name'};
	$ret{'name'} = $pfx{'name'};
	$ret{'prefix'} = $pfx{'prefix'};
	return \%ret;
}

sub distance {
	my($p1,$p2) = @_;
	my $dist    = greatc::distance($p1->{lat},$p1->{lng},$p2->{'lat'},$p2->{'lng'});
	my $bearing = greatc::bearing ($p1->{lat},$p1->{lng},$p2->{'lat'},$p2->{'lng'});
	return ($dist,$bearing);
}

1;
