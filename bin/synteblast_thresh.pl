#! /usr/bin/perl

use strict;
use warnings;


my $progname = $0;
$progname =~ s/^.*?([^\/]+)$/$1/;

my $usage = "\n";
$usage .=   "Usage: $progname [options]\n";
$usage .=   "Filter the synteblast table on STDIN for rows that meet the given thresholds and write to STDOUT. ";
$usage .=   "If no threshold parameters are provided, this script simply passess the entire table through.\n";
$usage .=   "       [-p P N] Minimum percent identity threshold P (0) and optionally, the input column N (5).\n";
$usage .=   "       [-c C M] Minimum percent query coverage threshold C (0) and optionally, the input column M (6).\n";
$usage .=   "\n";

my ($t_pctid, $t_qcovs, $pcol, $qcol) = (0, 0, 5, 6);

while (@ARGV) {
  my $arg = shift;
  if ($arg eq '-h' or $arg eq '-help') {
		die "$usage";
  } elsif ($arg eq '-p' or $arg eq '-pctid') {
		defined ($t_pctid = shift) or die "FATAL : -p argument is misformed: $!.";
		$pcol = shift unless scalar(@ARGV) == 0 or $ARGV[0] =~ /^\-/;
  } elsif ($arg eq '-c' or $arg eq '-qcovs') {
		defined ($t_qcovs = shift) or die "FATAL : -c argument is misformed: $!.";
		$qcol = shift unless scalar(@ARGV) == 0 or $ARGV[0] =~ /^\-/;
	}
}

die "$usage" unless defined $pcol and $pcol =~ /^\d+$/;
die "$usage" unless defined $qcol and $qcol =~ /^\d+$/;


my $rownum=0;
while (my $line=<>) {
	$rownum++;
	
	chomp $line;
	if ($line =~ /^\s*$/ or $line =~ /^#/) {
		print "$line\n";
		next;
	}
	
	my @cols = split /\t/, $line;
	if (scalar @cols < $pcol or scalar @cols < $qcol) {
		warn "WARN  : Row $rownum was passed through without thresholding; too few columns " . scalar(@cols) . ".\n";
		print "$line\n";
		next;
	}
	
	print "$line\n" if $cols[$pcol] >= $t_pctid and $cols[$qcol] >= $t_qcovs;
}

exit;
