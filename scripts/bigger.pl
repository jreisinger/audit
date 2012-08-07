#!/usr/bin/perl
# Find files bigger than some size.
use strict;
use warnings;
use 5.010;
use File::Find;
use Getopt::Long;

# Command line arguments
my $help       = 0;            # initial value
my $minsize    = 0;            # initial value
my $output     = 'term';       # initial value
my $options_ok = GetOptions(
    "help"      => \$help,
    "minsize=i" => \$minsize,
    "output=s"  => \$output,
);

# --help or uknown option
usage() if $help;
exit 1 unless $options_ok;

# --output
if ( $output eq 'csv' ) {
    my $outfile = "bigger.csv";
    die "File '$outfile' already present, not overwriting it.\n" if -e $outfile;
    open my $csv, ">", $outfile or die "Can't open $outfile for writing\n";
    select $csv;
} elsif ( $output eq 'term' ) {
    select STDOUT;    # default output
} else {
    usage() and die;
}

# Search directories
my %size;
@ARGV = qw( . ) unless @ARGV;   # if not directories supplied, search the current one
for my $dir ( @ARGV ) {
    die "'$dir' is not a directory\n" unless -d $dir;
}
find(\&wanted, @ARGV);

# Get the longest filepath
my $longest = 0;
for my $file ( keys %size ) {
    my $length = length $file;
    $longest = $length if $length > $longest;
}

# Print formatted output
for my $file ( sort { $size{$b} <=> $size{$a} } keys %size ) {
    my $size = add_000_separator( $size{$file} );
    # --output term
    if ( $output eq 'term' ) {
        my $number_of_dots = $longest - ( length $file ) + 3;
        printf "%-s %s %s\n", $file, '.' x $number_of_dots, $size;
    # --output csv
    } else {
        print "$file;$size\n";
    }
}

sub add_000_separator {
    my $number = shift;

    # Add comma each time through the do-nothing loop
    1 while $number =~ s/^(\d+)(\d\d\d)/$1,$2/;   # 1 is traditional placeholder
    $number;
}

sub usage {
    print "Usage: ", $0 =~ /([^\/]+)$/, " [ --help ] [ --size n ] [ --output csv|term ] [ <dir(s) to search> ]\n";
    print "Recursively search <dir(s) to search> for files that are bigger than n bytes.\n";
    print "\n";
    print "All arguments are optional.\n";
    print "  --minsize n         search for files bigger than n bytes, n defaults to 0\n";
    print "  --output csv|term   output goes to CSV file or terminal, defaults to term\n";
    print "  <dir(s) to search>  defaults to '.', meaning the current directory\n";
}

sub wanted {
    return unless -e;    # only take existing filenames
    return if -l;        # skip symbolic links
    my $size = -s;
    $size{$File::Find::name} = $size if $size > $minsize;
}
