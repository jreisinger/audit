#!/usr/bin/perl
# Generate text file of defined size.
# The size is not very precise, especially for very small files.
use strict;
use warnings;
use autodie;

my $file = shift;
my $size = shift;

die "Usage: $0 file size_in_bytes\n" if not defined $file or not defined $size;

open my $fh, ">", $file;

while ( -s $file < $size ) {
    my @words = qw( abcdef ghi jklmno prstuvw xyz );
    print $fh join( " ", @words ), "\n";
}

close $fh;
