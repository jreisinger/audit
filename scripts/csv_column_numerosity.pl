#!/usr/bin/perl
# Calculate the numerosity of items of a defined CSV column.
# Input: CSV data in UTF-8 format
#
# To convert Excel .csv to UTF-8
#   - open file.csv in Notepad
#   - File => Save As... => Encoding: UTF-8
use strict;
use warnings;
use Text::CSV_XS;

die "Usage: $0 <CSV file> <column number> [<separator>]\n"
  unless @ARGV == 2
      or @ARGV == 3;

############
# User input
my $csv_file  = shift;
my $column    = shift;           # 1-based column
my $separator = shift // ';';    # separator defaults to ;

################################
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

#####################
# Get the longest key
my $longest = 0;
for ( keys %count ) {
    $longest = length if length > $longest;
}

########
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
