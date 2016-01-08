
package LoTW;

my %lotw;

sub init {
	my($file) = @_;
	open(IN,"<",$file) || return undef;
	while(<IN>) {
		s,[\r\n\s],,g;
		if(/^([^,]+),([\d\-]+)$/) {
			$lotw{$1} = $2;
			next;
		}
		if(/^([^,]+)$/) {
			$lotw{$1} = '1970-01-01';
		}
	}
	close(IN);
}

sub check {
	return (defined $lotw{$_[0]}?'yes':'no');
}

1;
