############################################################################
# Skrypt PAR2 wer. 1.4
# Autor: Grzegorz Okoń - główny specjalista
#
# Wykonanie komend sql i zapis wyniku do pliku archiwum.
#
# Uruchomienie skryptu następuje komendą:
# perl PAR2.pl -i plik1.bat plik2.bat ...
#
# Wykonanie z opcją wykasowania nadmiarowych plików ponad ustawioną liczbę:
# perl PAR2.pl -i plik1.bat plik2.bat -h 7
#
# Uruchomienie z opcją porównania dwóch najnowszych plików:
# perl PAR2.pl -i plik1.bat plik2.bat -c
############################################################################

use strict;
use warnings;

my @input = ();
my $history = 0;
my $comparison = 0;
my $history_dir = ("./history");
my $comparison_dir = ("./comparison");

&handle_arguments;
&start_execution;
if ($history > 0) {
	&delete_files;
}
if ($comparison == 1) {
	&compare_history;
}

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
			} elsif (substr($ARGV[$argnum], 1, 1) eq "h") {
				for (my $i = $argnum + 1; $i <= $#ARGV; $i++) {
					if (substr($ARGV[$i], 0, 1) ne "-") {
						$history = $ARGV[$i];
					} else {
						last;
					}
				}
			} elsif (substr($ARGV[$argnum], 1, 1) eq "c") {
				$comparison = 1;
			}
		}			
	}
}

sub start_execution {
	foreach my $filenum (0 .. $#input) {
		my $filename = &create_filename_for_data($input[$filenum]);
		open FILE, "$input[$filenum]|";
		open OUTPUT, ">$history_dir/$filename" || die "can't create a file '$filename'";
		open OUTPUT, ">>$history_dir/$filename" || die "can't save to a file '$filename'";
		while (<FILE>) {
			print OUTPUT $_;
		}
		close FILE;
		close OUTPUT;
	}	
}

sub delete_files {
	foreach my $filenum (0 .. $#input) {
		my $filename = &substring_filename($input[$filenum]);
		my @history_files = &get_matching_files($filename, $history_dir);
		my @diff_files = &get_matching_files($filename . '_diff_', $comparison_dir);
		foreach my $pathnum (0 .. $#history_files) {
			if ($pathnum < ($#history_files - $history + 1)) {
				unlink $history_dir . '/' . $history_files[$pathnum];
			}
		}
		foreach my $pathnum (0 .. $#diff_files) {
			if ($pathnum < ($#diff_files - $history + 1)) {
				unlink $comparison_dir . '/' . $diff_files[$pathnum];
			}
		}
	}		
}

sub compare_history {
	foreach my $filenum (0 .. $#input) {
		my $filename = &substring_filename($input[$filenum]);
		my @files = ();
		opendir (DIR, $history_dir) || die "can't open a directory '$history_dir'";
		foreach (sort readdir(DIR)) {
			if ($_ ne '.' && $_ ne '..' && $_ =~ /$filename/) {
				push (@files, $_);
			}
		}
		close DIR;	
		if (@files > 1) {
			my $diff_filename = &create_filename_for_differences($input[$filenum]);
			open OUTPUT, ">$comparison_dir/$diff_filename" || die "can't create a file '$diff_filename'";
			open OUTPUT, ">>$comparison_dir/$diff_filename" || die "can't save to a file '$diff_filename'";
			open NEWEST_FILE, "$history_dir/$files[$#files]" or die "can't open a file '$files[$#files]'"; 
			open PREVIOUS_FILE, "$history_dir/$files[$#files - 1]" or die "can't open a file '$files[$#files - 1]'";
			my @newest_rows = <NEWEST_FILE>;
			my @previous_rows = <PREVIOUS_FILE>;
			foreach my $rownum (0 .. $#newest_rows) {
				if ($newest_rows[$rownum] ne $previous_rows[$rownum]) {
					print OUTPUT "There is a new value in line $rownum:\n";
					print OUTPUT "$newest_rows[$rownum]\n";
					print OUTPUT "An old value is:\n";
					print OUTPUT "$previous_rows[$rownum]\n\n";
				}
			}	
			close NEWEST_FILE;
			close PREVIOUS_FILE;			
			close OUTPUT;
		}
	}
}

sub create_filename_for_data {
	return &substring_filename($_[0]) . '_' . &get_timestamp . '.txt';
}

sub create_filename_for_differences {
	return &substring_filename($_[0]) . '_diff_' . &get_timestamp . '.txt';
}

sub get_timestamp {
	my @now = localtime();
	return sprintf("%04d-%02d-%02d", $now[5] + 1900, $now[4] + 1, $now[3]);
}

sub substring_filename {
	my $fullname = $_[0];
	my $position = rindex($fullname, '.');
	return substr($fullname, 0, $position);
}

sub get_matching_files {
	my $filename = $_[0];
	my $directory = $_[1];
	my @files = ();
	opendir (DIR, $directory) || die "can't open a directory '$directory'";
	foreach (sort readdir(DIR)) {
		if ($_ ne '.' && $_ ne '..' && $_ =~ /$filename/) {
			push (@files, $_);
		}
	}	
	close DIR;
	return @files;
}