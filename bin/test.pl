#! /usr/bin/perl -w

use strict;
use SimpleCluster;


my $k = 2;

my $pts = { "A" => [1,1], 
						"B" => [2,1], 
						"C" => [3,1], 
						"D" => [4,1], 
						"E" => [100,1], 
						"F" => [120,1], 
						"G" => [130,1], 
						"H" => [140,1], 
					};
					
my $ctrs = [ [2.5, 1],[125, 1] ];

my $clusters = SimpleCluster::kmeans($k, $pts, $ctrs);

my $count = 1;
print "\n# clusters\n";
foreach my $cluster (@$clusters) {
	print "$count\t" . join("\t", @$cluster) . "\n";
	$count++;
}

exit;

