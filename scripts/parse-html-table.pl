#!/usr/bin/perl
# Parse HTML tables.
# http://scott.wiersdorf.org/blog/perl/html_parser_table_parsing.html
use strict;
use warnings;

use HTML::Parser ();

my $state = '';
my @table = ();  ## @table = ( [foo,bar], [baz,blech] );
my @row   = ();  ## ("foo", "bar")
my $cell  = '';  ## "foo"

my $p = HTML::Parser->new( api_version => 3 );

$p->handler( start => sub {
    my $tag = shift;

    $state = 'TABLE' if $tag eq 'table';
    $state = 'TR'    if $tag eq 'tr';

    if( $state eq 'TD' ) {
        $cell .= shift;
    }

    $state = 'TD'    if $tag eq 'td';

}, "tagname,text" );

$p->handler( default => sub {
    $cell .= shift if $state eq 'TD';
}, "text" );

$p->handler( end => sub {
    my $tag = shift;

    if( $tag eq 'td' ) {
        $state = 'TR';
        push @row, $cell;

        $cell = '';
    }

    if( $tag eq 'tr' ) {
        $state = 'TABLE';
        push @table, [@row];

        @row = ();
    }

    $state = ''      if $tag eq 'table';

}, "tagname" );

## get the HTML table  
undef $/;
my $data = <DATA>;

## parse it (this calls each handler as necessary)
$p->parse($data);

## now dump out the Perl structures
use Data::Dumper;
for my $row ( @table ) {
    print Dumper($row);
}

exit;

__DATA__
<table>
  <tr>
    <td colspan=2>fat and wide</td>
  </tr>
  <tr>
    <td>foo</td>
    <td>bar</td>
  </tr>
  <tr>
    <td>baz</td>
    <td>blech</td>
  </tr>
</table>
