
package Master;

my %master;

sub init {
	my($file) = @_;
	open(IN,"<",$file) || return undef;
	while(<IN>) {
		chomp;
		s,[\r\n\s],,g;
		if(/^(.*)$/) {
			$master{$1} = 1;
		}
	}
	close(IN);
}

sub check {
	return (defined $master{$_[0]}?'yes':'no');
}

1;
