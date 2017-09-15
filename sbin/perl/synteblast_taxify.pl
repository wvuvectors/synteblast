#! /usr/bin/env perl -w
use strict;


my $progname = $0;
$progname =~ s/^.*?([^\/]+)$/$1/;

my $usage = "\n";
$usage .=   "Usage: $progname [options] COLNUM\n";
$usage .=   "Annotates WP_ ids in column COLNUM of table on STDIN with taxonomy information from NCBI. In many cases, a single ";
$usage .=   "WP_ id conceals proteins from multiple taxa (that all share the same sequence). This script will add a new row for ";
$usage .=   "each specific protein. All rows will have two added columns: one containing the specific id, the second containing the taxon.\n";

my $colnum = 3;

while (@ARGV) {
  my $arg = shift;
  if ($arg eq '-h' or $arg eq '-help') {
		die "$usage";
	} else {
		$colnum=$arg;
	}
}

die "$usage" unless defined $colnum and $colnum =~ /^\d+$/;

# each row contains a single blast hit, that may encompass proteins from multiple taxa with the identical sequence
my %matches = ();
while (my $line=<>) {

	chomp $line;
	next if $line =~ /^\s*$/ or $line =~ /^#/;
	
	my @cols = split /\t/, $line;
	
	my $qid   = "$cols[0]";
	my $wp_id = "$cols[$colnum]";
	$wp_id = $1 if $wp_id =~ /.+?\|.+?\|.+?\|(.+?)\|/;
	
	$matches{$qid} = {} unless defined $matches{$qid};
	$matches{$qid}->{$wp_id} = {"qlen" => $cols[1], "slen" => $cols[2], "eval" => $cols[4], "pident" => $cols[5], "qcovs" => $cols[6]};

}


open (my $tfh, ">", "ipg.tmp") or die "FATAL : No ipg tmp file created! $!";
print $tfh "#Source\tNucleotide Accession\tStart\tStop\tStrand\tProtein\tProtein Name\tOrganism\tStrain\tSuperkingdom\tWP_\tQuery\n";

foreach my $qid (keys %matches) {
	my @wp_ids = keys(%{$matches{$qid}});
	
	my $bin = 100;
	$bin = scalar @wp_ids if $bin > scalar @wp_ids;
	
	while (scalar @wp_ids > 0) {
		my @idsplice = splice(@wp_ids, 0, $bin);
		my $wp_sublist = join(",", @idsplice);
		warn "NOTE  : Querying NCBI for " . scalar(@idsplice) . " WP_ id matches to $qid.\n";
		#warn "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=protein&id=$wp_sublist&rettype=ipg&retmode=text\n\n";
		#die;
		my $ipgstr = `curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=protein&id=$wp_sublist&rettype=ipg&retmode=text"`;
	
		my @rows = split /\n/, $ipgstr;
		shift @rows;
		
		my $wp_id = "Unk";
		foreach my $row (@rows) {
			my @cols = split /\t/, $row, -1;
			shift @cols unless lc $cols[0] eq "refseq" or lc $cols[0] eq "insdc";
			next unless scalar @cols > 5;
			if (lc $cols[0] eq "refseq" and $cols[5] =~ /^WP_/i) {
				$wp_id = $cols[5];
			} elsif (lc $cols[0] eq "insdc") {
				print $tfh join("\t", @cols);
				print $tfh "\t$wp_id\t$qid\n";
			}
		}
		
		$bin = scalar @wp_ids if $bin > scalar @wp_ids;
	}
}

close $tfh;


open (my $ipgfh, "<", "ipg.tmp") or die "FATAL : Unable to open ipg tmp file for reading! $!";
print "#query_id\tquery_len\tsubject_len\tsubject_wp\tevalue\tpident\tquery_cov\tspecific_id\torganism\tstrain\tchr\tstart\tstop\tstrand\n";
while (my $line = <$ipgfh>) {
	chomp $line;
	next if $line =~ /^#/;
	
	my @cols = split /\t/, $line, -1;
	
	if (defined $matches{$cols[11]} and defined $matches{$cols[11]}->{$cols[10]}) {
		my $eref = $matches{$cols[11]}->{$cols[10]};
		print "$cols[11]\t$eref->{qlen}\t$eref->{slen}\t$cols[10]\t$eref->{eval}\t$eref->{pident}\t$eref->{qcovs}\t";
		print "$cols[5]\t$cols[7]\t$cols[8]\t$cols[1]\t$cols[2]\t$cols[3]\t$cols[4]\n";
	} else {
		warn "WARN  : Failed to find $cols[10] for $cols[11]";
	}
}
close $ipgfh;	


exit;

