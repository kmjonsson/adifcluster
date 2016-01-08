
package eQSL;

my %eqsl;

sub init {
	my($file) = @_;
	open(IN,"<",$file) || return undef;
	$_ = <IN>;
	while(<IN>) {
		chomp;
		s,[\r\n\s],,g;
		if(/^(\S+)$/) {
			$eqsl{$1} = 1;
		}
	}
	close(IN);
}

sub check {
	return (defined $eqsl{$_[0]}?'yes':'no');
}

1;
