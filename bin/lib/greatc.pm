
package greatc;

use Math::Trig qw(:great_circle deg2rad rad2deg);

# http://www.movable-type.co.uk/scripts/latlong.html
# http://perldoc.perl.org/Math/Trig.html

# Notice the 90 - latitude: phi zero is at the North Pole.
sub NESW { deg2rad($_[0]), deg2rad(90 - $_[1]) }

sub distance {
	my($lat1,$lng1,$lat2,$lng2) = @_;

	my @L = NESW( $lng1, $lat1);
	my @T = NESW( $lng2, $lat2);
	my $km = sprintf("%.0f",great_circle_distance(@L, @T, 6378));
	return $km;
}

sub bearing {
	my($lat1,$lng1,$lat2,$lng2) = @_;
	my @L = NESW( $lng1, $lat1);
	my @T = NESW( $lng2, $lat2);

	my $dir = sprintf("%.0f",rad2deg(great_circle_bearing(@L, @T)));
	return $dir;

}

1;
