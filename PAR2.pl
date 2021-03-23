##########################################################
# Skrypt PAR2 wer. 1.2
# Autor: Grzegorz Okoń - główny specjalista
#
# Wykonanie komend sql i zapis wyniku do pliku archiwum.
#
# Uruchomienie skryptu następuje komendą:
# perl PAR2.pl -i plik1.bat plik2.bat ...
##########################################################

use strict;
use warnings;

my @input = ();

&handle_arguments;
&execute;

sub handle_arguments {
	foreach my $argnum (0 .. $#ARGV) {
		if (substr($ARGV[$argnum], 0, 1) eq "-") {
			if (substr($ARGV[$argnum], 1, 1) eq "i") {
				for (my $i = $argnum + 1; $i <= $#ARGV; $i++) {
					if (substr($ARGV[$i], 0, 1) ne "-") {
						push (@input, $ARGV[$i]);
					} else {
						last;
					}
				}
			}
		}			
	}
}

sub execute {
	foreach (@input) {
		my $filename = &create_output_filename($_);
		open FILE, "$_|";
		open OUTPUT, ">>./history/$filename" || die "can't create a file";
		open OUTPUT, ">>./history/$filename" || die "can't save to a file";
		while (<FILE>) {
			print OUTPUT $_;
		}
		close FILE;
		close OUTPUT;
	}	
}

sub create_output_filename {
	my $fullname = $_[0];
	my $position = rindex($fullname, '.');
	my $filename = substr($fullname, 0, $position);
	my @now = localtime();
	my $timestamp = sprintf("%04d-%02d-%02d", $now[5]+1900, $now[4]+1, $now[3]);
	return $filename . '_' . $timestamp . '.txt';
}