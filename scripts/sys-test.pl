#!/usr/bin/perl
# Run as: perl sys-test.pl > /tmp/out 2>&1
use strict;
use warnings;
use User::pwent;    # overrides normal getpwent()
use File::stat;     # overrides normal stat()
use Test::More 'no_plan';

## Configuration

my @files = (
    {
        name  => '/etc/passwd',
        owner => 'root',
        group => 'root',
        perms => '0644',
    },
    {
        name  => '/etc/group',
        owner => 'root',
        group => 'root',
        perms => '0644',
    },
    {
        name  => '/etc/shadow',
        owner => 'root',
        group => 'shadow',
        perms => '0640',
    },
);

## Collect info

# Collect system users (from /etc/passwd || NIS || LDAP)
my $fmt = "%15s %35s %20s %20s\n";
printf $fmt, qw(Name Gecos Home Shell);
while ( my $pwent = getpwent() ) {
    printf $fmt, $pwent->name, $pwent->gecos, $pwent->dir, $pwent->shell;
}
endpwent();

## Run checks

# Files' owner and permissions
for my $file (@files) {
    my $name  = $file->{name};
    my $perms = $file->{perms};
    my $owner = $file->{owner};
    my $group = $file->{group};
    is( access_rights($name), $perms, "perms of $name" );
    is( owner($name),         $owner, "owner of $name" );
    is( group($name),         $group, "group of $name" );
}

# Duplicate UIDs
my @dups = duplicate_uids();
is( @dups, 0, "duplicate uids (@dups)" );

# PATH contains "."
is( check_path(),         1, "$ENV{USER}'s PATH contains dot" );
is( check_profile_path(), 1, "/etc/profile's PATH contains dot" );

## Functions

sub check_profile_path {
    my $file = "/etc/profile";
    open my $fh, "<", $file or die "Cant' open $file: $!";
    while (<$fh>) {
        next unless /PATH=/;
        next unless /\./;
        return $_;
    }
    close $fh;
    return 1;
}

sub check_path {
    my @dirs = split ":", $ENV{PATH};
    for (@dirs) {
        next unless /\./;
        return join ":", @dirs;
    }
    return 1;
}

sub duplicate_uids {
    my @uids;
    while ( my $pwent = getpwent() ) {
        push @uids, $pwent->uid;
    }
    endpwent();
    my %seen = ();
    my @dups = grep { $seen{$_}++ } @uids;
    if (@dups) {
        return @dups;
    } else {
        return 0;
    }
}

sub owner {
    my $filename = shift;
    return unless -e $filename;
    my $stat  = stat($filename);
    my $pwent = getpwuid( $stat->uid );
    return $pwent->name;
}

sub group {
    my $filename = shift;
    return unless -e $filename;
    my $stat  = stat($filename);
    my $group = getgrgid( $stat->gid );
    return $group;
}

sub access_rights {
    my $filename = shift;
    return unless -e $filename;
    my $stat = stat($filename);
    my $perms = sprintf "%04o", $stat->mode & 07777;    # discard file type info
    return $perms;
}
