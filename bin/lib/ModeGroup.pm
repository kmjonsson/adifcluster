
package ModeGroup;

my(%mode_group) = (
		'THRB' => 'DATA',
		'CW' => 'CW',
		'PHONE' => 'PHONE',
		'IMAGE' => 'IMAGE',
		'DATA' => 'DATA',
		'AM' => 'PHONE',
		'FM' => 'PHONE',
		'LSB' => 'PHONE',
		'USB' => 'PHONE',
		'SSB' => 'PHONE',
		'ATV' => 'IMAGE',
		'FAX' => 'IMAGE',
		'SSTV' => 'IMAGE',
		'AMTOR' => 'DATA',
		'CHIP' => 'DATA',
		'CLOVER' => 'DATA',
		'CONTESTI' => 'DATA',
		'DOMINO' => 'DATA',
		'FSK31' => 'DATA',
		'FSK441' => 'DATA',
		'GTOR' => 'DATA',
		'HELL' => 'DATA',
		'HFSK' => 'DATA',
		'ISCAT' => 'DATA',
		'JT4' => 'DATA',
		'JT65' => 'DATA',
		'JT6M' => 'DATA',
		'JT9' => 'DATA',
		'MFSK16' => 'DATA',
		'MFSK8' => 'DATA',
		'MINIRTTY' => 'DATA',
		'MT63' => 'DATA',
		'OLIVIA' => 'DATA',
		'OPERA' => 'DATA',
		'PACKET' => 'DATA',
		'PACTOR' => 'DATA',
		'PAX' => 'DATA',
		'PSK10' => 'DATA',
		'PSK125' => 'DATA',
		'PSK2K' => 'DATA',
		'PSK31' => 'DATA',
		'PSK63' => 'DATA',
		'PSK63F' => 'DATA',
		'PSKAM' => 'DATA',
		'PSKFEC31' => 'DATA',
		'Q15' => 'DATA',
		'ROS' => 'DATA',
		'RTTY' => 'DATA',
		'RTTYM' => 'DATA',
		'THOR' => 'DATA',
		'THROB' => 'DATA',
		'VOI' => 'DATA',
		'WINMOR' => 'DATA',
		'WSPR' => 'DATA'
);

sub convert {
	my($mode) = @_;
	return $mode_group{$mode};
}

1;
