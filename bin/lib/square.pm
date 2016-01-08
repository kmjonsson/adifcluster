
package square;

sub four {
	my($square) = @_;
	my @grid = split (//, uc($square));
	my $lon = (ord($grid[0]) - ord('A')) * 20 - 180;
	my $lat = (ord($grid[1]) - ord('A')) * 10 - 90;
	$lon   += (ord($grid[2]) - ord('0')) * 2;
	$lat   += (ord($grid[3]) - ord('0')) * 1;
	return ($lat,$lon);
}
sub six {
	my($square) = @_;
	my($lat,$lon) = four($square);
	my @grid = split (//, uc($square));
	$lon += ((ord($grid[4])) - ord('A')) * 5/60;
	$lat += ((ord($grid[5])) - ord('A')) * 2.5/60;
	return ($lat,$lon);
}

1;
