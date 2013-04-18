#!/usr/bin/perl
# Get some persons' companies from foaf.sk and compare them with suppliers
use strict;
use warnings;
use LWP::Simple qw(get);
use HTML::TokeParser;
use Data::Dumper qw(Dumper);
use open qw(:std :utf8);    # undeclared streams in UTF-8

# Input files
my $ids       = read_ids("ids.txt");
my $suppliers = read_suppliers("suppliers.csv");

my $base_url = "http://foaf.sk/ludia/";

my %ids_with_data;

ID: for my $id (@$ids) {

    # get page
    my $html = get( $base_url . $id );

    # get list of related companies
    my $parser = HTML::TokeParser->new( \$html );
    my $in     = 0;
    while ( my $token = $parser->get_token ) {
        my $type = $token->[0] // "";
        my $tag  = $token->[1] // "";

        if ( $type eq "T" ) {
            my $text = $token->[1];
            my ($name) = $text =~ /([^|]+)\s+\|\s*foaf\.sk/;

            #print "$name ($id)\n" if $name;
            $ids_with_data{$id}{name} = $name if $name;
        }

        if ( $type eq "S" and $tag eq "p" ) {
            my $attr  = $token->[2]      // "";    # href
            my $class = $attr->{'class'} // "";

            # we are inside list of related companies
            $in = 1 if $class eq "related";
        } elsif ( $type eq "E" and $tag eq "p" ) {
            $in = 0;

            # we are done with the list of companies go to next ID
            next ID;
        }

        # we are inside list of related companies with links and commas
        #  (see HTML source)
        if ($in) {
            if ( $type eq "T" ) {
                my $text = $token->[1];

                #print "\t$text\n" unless $text =~ /^[,\s]+$/;
                push @{ $ids_with_data{$id}{companies} }, $text
                  unless $text =~ /^[,\s]+$/;
            }
        }

    }

}

#print Dumper \%ids_with_data;
#print Dumper $suppliers;

# compare with list of ST suppliers
for my $id ( keys %ids_with_data ) {
    for my $company ( @{ $ids_with_data{$id}{companies} } ) {
        my $company_short = fix_company_name($company);
        my @matched = grep { /$company_short/i } keys %$suppliers;
        print "Matched [$company_short]: $company ($ids_with_data{$id}{name})\n"
          if @matched;
        for (@matched) {

            if ( $suppliers->{$_} <= -5000 ) {
            #if ( $suppliers->{$_} != 0 ) {
                print "\t$_ ($suppliers->{$_})\n";
            }
        }
    }
}

sub fix_company_name {
    my $name = shift;
    #my ($new_name) = $name =~ /^\s*(\S+\s+\S+)/;
    my ($new_name) = $name =~ /^\s*(\S+)/;
    return $new_name;
}

sub read_ids {
    my $file = shift;
    open my $fh, "<", $file or die "$file: $!";
    chomp( my @ids = <$fh> );
    close $fh;
    return \@ids;
}

sub read_suppliers {
    my $file = shift;
    open my $fh, "<", $file or die "$file: $!";
    my %supplier;
    while ( my $line = <$fh> ) {
        my ( $name, $turnover_2012 ) = split ";", $line;
        $supplier{$name} += $turnover_2012;
    }
    close $fh;
    return \%supplier;
}
