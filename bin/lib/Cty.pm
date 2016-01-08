
package Cty;

use Data::Dumper;


my %special = (
        KG4 => [ 
					{ regexp => '^KG4[A-Z]$'   , is => 'K' },
					{ regexp => '^KG4[A-Z]{3}$', is => 'K' },
				],  
);  

my %extracalls = (
        'FH' => ['TO7BC'],
        );

sub fixCty {
	my($cty) = @_;
	my %res = (
		'maxLength' => 0,
		'prefixes' => {},
		'calls' => {},
	);
	foreach my $c (@$cty) {
		$c->{special} = $special{$c->{prefix}} if exists $special{$c->{prefix}};
		foreach my $pfx (@{$c->{prefixes}}) {
			my($p,$nc) = parsePfx($pfx,$c);
			$res{maxLength} = length($p) if $res{maxLength} < length($p);
			$res{prefixes}->{$p} = $nc;
		}
		foreach my $call (@{$c->{calls}}) {
			$res{calls}->{$call} = $c
		}
		if(exists $extracall{$c->{prefix}}) {
			foreach my $call (@{$extracall{$c->{prefix}}}) {
				$res{calls}->{$call} = $c
			}
		}
	}
	return \%res;
}

sub dupeCty {
	my($c) = @_;
	my %r = %$c;
	return \%r;
}

sub parsePfx {
	my($pfx,$c) = @_;
	my %r;
	if($pfx =~ s,\((\d+)\),,) {
		$r{cqzone} = $1;
	}
	if($pfx =~ s,\[(\d+)\],,) {
		$r{itureg} = $1;
	}
	if(scalar keys %r) {
		my $nc = dupeCty($c);
		foreach my $k (%r) {
			$nc->{$k} = $r{$k};
		}
		return ($pfx,$nc);
	}
	return ($pfx,$c);
}

sub parseFile {
	my($file) = @_;
	local *IN;
	open(IN,"<" . $file) || return undef;
	my @cty;
	my $curr;
	while(<IN>) {
		s,[\r\n]+$,,;
		if(/^([^:]+):\s+(\d+):\s+(\d+):\s+(EU|AS|AF|OC|NA|SA):\s+([^:]+):\s+([^:]+):\s+([^:]+):\s+(\S+):\s*$/) {
			push @cty,$curr if defined $curr;
			$curr = {
				'name' => $1,
				'cqzone' => int($2),
				'itureg' => int($3),
				'continent' => $4,
				'lat' => $5,
				'lng' => -$6,
				'gmtoffset' => int($7),
				'prefix' => $8,
				'prefixes' => [],
				'calls' => [],
				'nodxcc' => 0,
			};
			$curr->{lat} =~ s,^\+,,;
			$curr->{lng} =~ s,^\+,,;
			if($curr->{prefix} =~ /^\*/) {
				$curr->{nodxcc} = 1;
				$curr->{prefix} =~ s,^\*,,;
			}
			next;
		}
		if(defined $curr && /^\s+(\S+)(;|,)\s*$/) {
			foreach my $pc (split(/,/,$1)) {
				if($pc =~ /^=/) {
					push @{$curr->{calls}},$';
				} else {
					push @{$curr->{prefixes}},$pc;
				}
			}
			next;
		}
		die "'$_'\n";
	}
	push @cty,$curr if defined $curr;
	close(IN);
	return \@cty;
}

1;
