############################################################################
# Skrypt PAR2 wer. 1.3
# Autor: Grzegorz Okoń - główny specjalista
#
# Wykonanie komend sql i zapis wyniku do pliku archiwum.
#
# Uruchomienie skryptu następuje komendą:
# perl PAR2.pl -i plik1.bat plik2.bat ...
#
# Wykonanie z opcją wykasowania nadmiarowych plików ponad ustawioną liczbę:
# perl PAR2.pl -i plik1.bat plik2.bat -h 7
############################################################################

use strict;
use warnings;

my @input = ();
my $history = 0;

&handle_arguments;
&start_execution;
if ($history > 0) {
    &delete_history;
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
            }                                            
        }
	}
}

sub start_execution {
    foreach my $filenum (0 .. $#input) {
        my $filename = &create_filename($input[$filenum]);
        open FILE, "$input[$filenum]|";
        open OUTPUT, ">./history/$filename" || die "can't create a file '$filename'";
        open OUTPUT, ">>./history/$filename" || die "can't save to a file '$filename'";
        while (<FILE>) {
            print OUTPUT $_;
        }
        close FILE;
        close OUTPUT;
    }             
}

sub create_filename {
    my @now = localtime();
    my $timestamp = sprintf("%04d-%02d-%02d", $now[5]+1900, $now[4]+1, $now[3]);
    return &substring_filename($_[0]) . '_' . $timestamp . '.txt';
}

sub substring_filename {
    my $fullname = $_[0];
    my $position = rindex($fullname, '.');
    return substr($fullname, 0, $position);
}

sub delete_history {
    my $directory = ("./history");
    foreach my $filenum (0 .. $#input) {
        my $filename = &substring_filename($input[$filenum]);
        my @files = ();
        opendir (DIR, $directory) || die "can't open a directory '$directory'";
        foreach (sort readdir(DIR)) {
            if ($_ ne '.' && $_ ne '..' && $_ =~ /$filename/) {
                push (@files, $_);
            }
        }             
        close DIR;           
        foreach my $pathnum (0 .. $#files) {
            if ($pathnum < ($#files - $history + 1)) {
                unlink $directory .  '/' . $files[$pathnum];
            }
        }
    }                             
}