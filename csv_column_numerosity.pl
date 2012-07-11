#!/usr/bin/perl
# Get the numerosity of items of a defined column.
# Input: CSV data in UTF-8 format
#
# Excel unicode: http://www.excelforum.com/excel-general/400043-csv-and-unicode-or-utf-8-problem.html
# Perl unicode: http://ahinea.com/en/tech/perl-unicode-struggle.html
use strict;
use warnings;
use Text::CSV_XS;

die "Usage: $0 <CSV file> <column number> [<separator>]\n" unless @ARGV == 2;

my $csv_file  = shift;
my $column    = shift;           # 1-based column
my $separator = shift // ';';    # separator defaults to ;

# Read in and count the CSV data
my @rows;
my $csv = Text::CSV_XS->new( { binary => 1, sep_char => $separator } )
  or die "Cannot use CSV: " . Text::CSV_XS->error_diag();
open my $fh, "<:encoding(utf8)", "$csv_file" or die "$csv_file: $!";
my %count;
while ( my $row = $csv->getline($fh) ) {
    $count{ $row->[ $column - 1 ] }++;
}
$csv->eof or $csv->error_diag();
close $fh;

# Get the longest key
my $longest = 0;
for ( keys %count ) {
    $longest = length if length > $longest;
}

# Output
binmode STDOUT, ":utf8";    # output in UTF-8
my $format = "%-${longest}s ... %d\n";
my $total;
print "\n";
for ( sort by_value keys %count ) {
    printf $format, $_, $count{$_};
    $total += $count{$_};
}

sub by_value {
    $count{$b} <=> $count{$a};
}

print "-" x ( $longest + 5 + length $total ) . "\n";
printf $format, "Total", $total;
