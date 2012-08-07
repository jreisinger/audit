#!/usr/bin/perl
# Parse /etc/shadow for last password change.
use strict;
use warnings;

# Leave this array empty to get all logins
my @interesting_logins = qw (
  root
  user1
  user2
);

my %pw_change;
while (<>) {
    my ( $login, undef, $last_pw_change ) = split /:/, $_;
    if (@interesting_logins) {
        next unless ( grep $login eq $_, @interesting_logins );
    }
    $last_pw_change = 0 if $last_pw_change eq "";
    $pw_change{$login} = time() / 86400 - $last_pw_change;  # days ago
    # next comes here ##
}

# sort values by numbers, descending
for my $login ( sort { $pw_change{$b} <=> $pw_change{$a} } keys %pw_change )
{
    printf "%-12s %5.0f days (cca. %02.1f years) ago\n",
      $login, $pw_change{$login}, $pw_change{$login} / 365;
}
