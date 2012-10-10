#!/usr/bin/perl
# Collect Linux/Solaris system information.
use strict;
use warnings;
use Sys::Hostname;  # core module

# Detect OS
my $os = $^O;

# Files to cat and list
my @cat_files = qw{
    /etc/passwd
    /etc/group
    /etc/shadow
    /etc/syslog.conf
    /etc/rsyslog.conf
};

# Commands to execute
my @linux_cmds = (
    "uname -a",
    "uptime",
    "ps -ef",
    "netstat -tlpna", 
    "crontab -l",
    "ifconfig -a",
    "df -h",
    );
my @solaris_cmds = (
    "/usr/bin/uname -a",
    "/usr/bin/uptime",
    "/usr/ucb/ps -wwxaa",
    "/usr/bin/netstat -an | grep LISTEN", 
    "/usr/bin/crontab -l",
    "/usr/bin/svcs -a",
    "/sbin/ifconfig -a",
    "/usr/sbin/df -h",
    );
my @cmds;
if ($os eq 'linux') {         # OS is linux
  @cmds = @linux_cmds;
} elsif ($os eq 'solaris') {  # OS is solaris
  @cmds = @solaris_cmds;
} else {                      # Other OS - defaults to linux
  @cmds = @linux_cmds;
}

# Check you are root
die "You must be root to run this script\n" unless $> == 0;

# Timestamp for output file
my($sec, $min, $hour, $day, $mon, $year, undef, undef, undef) = localtime(time);
my $timestamp = sprintf "%04d%02d%02d_%02d%02d%02d", $year + 1900, $mon + 1, $day, $hour, $min, $sec;

# Create or everwrite output file
my $out_file = hostname . "_$timestamp.out";        # output filename (actual hostname)
if (-e $out_file) {
    while (1) {
        print "File '$out_file' already exists. Overwrite (y|n)?: ";
        chomp(my $input = <STDIN>);
        if ($input =~ /^[Y]$/i) {      # Match Yy
            open(FH,">","$out_file") or die "Can't create '$out_file': $!\n";
            close(FH);
            last;
        } elsif ($input =~ /^[N]$/i) {  # Match Nn
            die "Exiting...\n";
        } else {
            print "What? Try again...\n"
        }
    }
} else {
    open(FH,">","$out_file") or die "Can't create '$out_file': $!\n";
    close(FH);
}

## MAIN BODY ##

# Open output file
open OUT_FILE, ">>", "$out_file" or die "Can't open '$out_file': $!\n";

# System info
my $n;
foreach my $cmd (@cmds) {
        run_cmd("$cmd");
        $n++;   # count cycles (just info)
}
print "$n commands executed, output stored to '$out_file'\n";

# File attributes
$n = 0;
foreach my $file (@cat_files) {
    ls_file("$file");
        $n++;
}
print "'ls -l' run on $n files, output stored to '$out_file'\n";

# File contents
foreach my $file (@cat_files) {
    cat_file("$file");
}

# Close output file
close OUT_FILE;

## FUNCTIONS ##

sub cat_file {
    # Print file contents to output file
    my $in_file = shift @_;
    print OUT_FILE "### '$in_file' START ###\n";
    if ( ! open IN_FILE, $in_file ) {
        print OUT_FILE "Can't open '$in_file': $!\n";
    } elsif ( $in_file =~ /^.*shadow.*$/ ) {   # shadow file
        my $n=0;
        foreach my $line (<IN_FILE>) {
            my @fields = split (/:/, $line);    # 9 fields
            print OUT_FILE join(':', $fields[0], , 'X', $fields[2], $fields[4], $fields[5], $fields[6], $fields[7], $fields[8]);
            $n++;
        }
        print "$n lines from '$in_file' stored to '$out_file' (sanitized)\n";
    } else {
        my $n=0;
        foreach my $line (<IN_FILE>) {
            print OUT_FILE $line;
            $n++;
        }
        print "$n lines from '$in_file' stored to '$out_file'\n";
    }
    close IN_FILE;
    print OUT_FILE "### '$in_file' END ###\n\n";
}

sub ls_file {
        my $file = shift @_;
        my $ls_out = `ls -l $file 2>&1`;
        $ls_out = "$!\n" unless $ls_out;
        print OUT_FILE "### 'ls -l $file':\n$ls_out\n";
}

sub run_cmd {
        my $cmd = shift @_;
        my $cmd_out = `$cmd 2>&1`;
        $cmd_out = "$!\n" unless $cmd_out;
        print OUT_FILE "### '$cmd' output:\n$cmd_out\n";
}

