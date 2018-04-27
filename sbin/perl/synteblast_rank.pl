#! /usr/bin/env perl -w
use strict;

use Algorithm::NeedlemanWunsch;

use File::Basename;
use lib dirname(__FILE__) . "/lib";
use SimpleCluster;


my $progname = $0;
$progname =~ s/^.*?([^\/]+)$/$1/;

my $usage = "\n";
$usage .=   "Usage: $progname [options]\n";
$usage .=   "Accepts a synteblast table on STDIN and assembles into a ranked grid. The -i option is required ";
$usage .=   "and provides a reference for the proper ordering of entries.\n";
$usage .=   "       [-i F] Use the fasta file F to determine the order of genes.\n";
$usage .=   "\n";


my $referencef;

while (@ARGV) {
  my $arg = shift;
  if ($arg eq '-h' or $arg eq '-help') {
		die "$usage";
  } elsif ($arg eq '-i' or $arg eq '-in') {
		defined ($referencef = shift) or die "FATAL : -i argument is misformed: $!";
	}
}

die "FATAL : A reference file is required, but not provided. Use the -i option.\n$usage\n" unless defined $referencef;
die "FATAL : A reference file was provided ($referencef), but I am unable to read it." unless -f "$referencef";


my $seq_count     = 0;
my %chr2taxon     = ();
$chr2taxon{"ref"} = "ref";
my %qid2pos       = ();

my %master      = ();
$master{"ref"}  = {};

open my $rfh, "<", "$referencef" or die "FATAL : Unable to open reference fasta file $referencef for reading: $1";
while (my $line = <$rfh>) {
	chomp $line;
	if ($line =~ /^>/) {
		$line =~ s/^>//;
		$seq_count++;
		my ($qid, $ann) = split /\s+/, "$line", 2;
		if ($qid =~ /\|/) {
			$qid .= "|" unless $qid =~ /\|$/;
			#$qid = $1 if $qid =~ /.+?\|.+?\|.+?\|(.+?)\|/ or $qid =~ /.+?\|(.+?)\|/;
		}
		$master{"ref"}->{$seq_count} = {
			"start"       => $seq_count, 
			"stop"        => $seq_count, 
			"pident"      => 100, 
			"qcovs"       => 100, 
			"strand"      => 0, 
			"match_id"    => $qid, 
			"query_id"    => $qid, 
			"query_pos"   => $seq_count, 
			"score"       => 1
		};
		$qid2pos{$qid} = $seq_count;
	}
}
close $rfh;

#print Dumper(\%master);
#die;

# columns in the input table
#  0 query_id
#  1 query_len
#  2 subject_len
#  3 subject_wp
#  4 evalue
#  5 pident
#  6 query_cov
#  7 specific_id
#  8 organism
#  9 strain
# 10 chr
# 11 start
# 12 stop
# 13 strand

# need to identify any chromosomes that have multiple matches to the same query
# these represent possible copies of the input (query) operon and will be disentangled later
my %dups = ();

while (my $line=<>) {

	chomp $line;
	next if $line =~ /^\s*$/ or $line =~ /^#/;
	my @cols = split /\t/, $line, -1;
	
	my $tax = "$cols[8]";
	$tax .= " $cols[9]" unless "" eq $cols[9] or index($tax, $cols[9]) != -1;
	
	# key master hash by chr
	my $chr = $cols[10];
	$master{$chr} = {} unless defined $master{$chr};
	$chr2taxon{$chr} = $tax;
	
	# look through existing entries on this chr to see if a match to this query already exists
	# if so, store the number of matches to the query that are found
	foreach my $pos (keys %{$master{$chr}}) {
		if ("$cols[0]" eq "$master{$chr}->{$pos}->{query_id}") {
			$dups{$chr} = {} unless defined $dups{$chr};
			$dups{$chr}->{$cols[0]} = 1 unless defined $dups{$chr}->{$cols[0]};
			$dups{$chr}->{$cols[0]} = $dups{$chr}->{$cols[0]} + 1;
		}
	}
	
	# key chrs by match start position
	$master{$chr}->{$cols[11]} = {} unless defined $master{$chr}->{$cols[11]};
	
	my $strand = 1;
	$strand = 0 if "$cols[13]" eq "-";
	
	my $score = ($cols[5]/100) * ($cols[6]/100);
	
	# key queries by start position
	$master{$chr}->{$cols[11]} = {
		"start"       => $cols[11], 
		"stop"        => $cols[12], 
		"pident"      => $cols[5], 
		"qcovs"       => $cols[6], 
		"strand"      => $strand, 
		"match_id"    => $cols[7], 
		"query_id"    => $cols[0], 
		"query_pos"   => $qid2pos{$cols[0]}, 
		"score"       => $score
	};
}

#print Dumper(\%dups);
#die;

# calculate putative number of 'duplicate' blocks on chromosomes with more than one match to a query
# this will serve as k, the number of blocks (clusters) to generate
my @dup_chrs = keys %dups;
foreach my $chr (@dup_chrs) {
	my @sorted_qids = sort { $master{$chr}->{$b} <=> $master{$chr}->{$a} } keys %{$master{$chr}};
	my $k = $master{$chr}->{shift(@sorted_qids)};
	$dups{$chr} = $k;
}

# determine the query id at the middle of the input block
# this will serve as the initial centroid seeds for clustering the blocks
my $midblock_query = int(scalar(keys %{$master{"ref"}}) / 2) + 1;
$midblock_query = $master{"ref"}->{$midblock_query}->{"query_id"};

# separate multiple syntenic blocks on the same chromosome
foreach my $chr (keys %dups) {
	my $k = $dups{$chr};
	
	# find all the matches on this chromosome
	my %pts  = ();
	my @ctrs = ();
	foreach my $pos (keys %{$master{$chr}}) {
		$pts{$master{$chr}->{$pos}->{"match_id"}}  = [$pos, 1];
		push @ctrs, [$pos, 1] if "$master{$chr}->{$pos}->{query_id}" eq "$midblock_query";
	}
	
	# use k-means clustering to determine block configuration
	# returns an array ref of array refs, each holding the ids contained in an individual cluster
	my $clusters = SimpleCluster::kmeans($k, \%pts, \@ctrs);

#	print Dumper($clusters);
	
	# move duplicate clusters to derivative chromosomes
	for ( my $i=1; $i<scalar(@$clusters); $i++ ) {
		$master{"$chr-$i"} = {};
		for ( my $j=0; $j<scalar(@{$clusters->[$i]}); $j++ ) {
			my $match_id = $clusters->[$i]->[$j];
			my $pos = $pts{$match_id}->[0];
			$master{"$chr-$i"}->{$pos} = delete $master{$chr}->{$pos};
		}
	}
}

#print Dumper(\%master);
#die;


# calculate scores for synteny (colinearity; C), strandedness (S), and occupancy (U) on each chromosome
# 
my $Ur = scalar keys %{$master{"ref"}};
my @Ar = (1..$seq_count);
my $matcher = Algorithm::NeedlemanWunsch->new(\&score_sub);

foreach my $chr (keys %master) {

	# calculate U, C, and S for this chromosome
	my $U = 1;	# number of queries / number of queries in reference
	my $C = 1;	# 1 - global sequence alignment of ordered arrays of queries
	#my $S = 1;	# 1 - Euclidean distance between arrays of query strands?
	
	$U = scalar(keys(%{$master{$chr}})) / $Ur;
	my @A = ();
	foreach (sort {$a <=> $b} keys %{$master{$chr}}) {
		push @A, $master{$chr}->{$_}->{"query_pos"};
		$master{$chr}->{$A[-1]} = delete $master{$chr}->{$_};
	}
	$master{$chr}->{"seq"} = join("", @A);
	$C = $matcher->align(	\@Ar, 
												\@A, 
												{ align        => \&on_align, 
													shift_a      => \&on_shift_a, 
													shift_b      => \&on_shift_b 
												}
											);


	$master{$chr}->{"U"} = $U;
	$master{$chr}->{"C"} = $C;
	#$master{$chr}->{"S"} = $S;
}

#print Dumper(\%master);
#die;

# add taxon to the master hash for display sorting purposes
foreach my $chr (keys %master) {
	my $ochr = "$chr";
	$ochr = $1 if $chr =~ /^(.+?)\-\d+$/i;
	$master{$chr}->{"tax"} = "$chr2taxon{$ochr}";
}

my @chr_rank = sort { $master{$b}->{"C"} <=> $master{$a}->{"C"} or 
											$master{$b}->{"U"} <=> $master{$a}->{"U"} or 
											$master{$a}->{"tax"} cmp $master{$b}->{"tax"} 
										} keys %master;

print "#tax\tchromosome\talign_score\toccupancy";
foreach (1..$seq_count) {
	print "\t$master{ref}->{$_}->{query_id}";
}
print "\n";
foreach my $chr (@chr_rank) {
	next if "$chr" eq "ref";
	
	my $ochr = "$chr";
	$ochr = $1 if $chr =~ /^(.+?)\-\d+$/i;
	
	print "$chr2taxon{$ochr}\t$ochr\t$master{$chr}->{C}\t$master{$chr}->{U}";
	foreach (1..$seq_count) {
		print "\t";
		if (defined $master{$chr}->{$_}) {
			print "$master{$chr}->{$_}->{match_id}";
		} else {
			print "-";
		}
	}
	print "\n";
}

exit;



sub score_sub {
	if (!@_) {
		return -2; # gap penalty
	}

	return ("$_[0]" eq "$_[1]") ? 1 : -1;
}

sub on_align {
}

sub on_shift_a {
}

sub on_shift_b {
}

sub on_select_align {
}


