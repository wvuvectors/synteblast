package SimpleCluster;

=pod
	k is an integer representing the number of clusters to create.
	pts is a ref to a hash of array refs, keyed by point id, containing coordinates of points to cluster.
	ctrs is a ref to an array of array refs containing starting center points to use. its length must equal k.
	
	pointsets = [ [x,x], [y,y], [z,z], [p,p], [q,q], [r,r] ]
	clusters  = [ [0, 1], [2, 3] ]
	centroids = [ [m, m], [n, n] ]

=cut

sub kmeans {
	my ( $k, $pts, $ctrs ) = @_;
	
	my $err = validate_input(@_);
	die "FATAL : the input to Cluster::kmeans is not valid:\n$err" unless $err eq "";
	
	my $debug  = 0;
	
	my $thresh = 0.02;
	my $delta  = 20;
	my $bugout = 1000;
	
	my @pointset  = ();	# array of array refs holding the n-dim points to cluster. The index can be used to look up the original id in %id2int.
	my %indx2id   = ();	# hash mapping indices in the @pointset array to input point ids (which may be any type).

	my @centroids = ();	# array of array refs holding the n-dim centroid coordinates. prefilled from ctrs if provided.
	my @clusters  = ();	# array of array refs holding indices of clustered entries in the @pointset array


	foreach my $id (keys %$pts) {
		# map the incoming ids to integers for clustering
		$indx2id{scalar(@pointset)} = $id;
		# push the coordinates into the pointset array
		my @a = ();
		foreach (@{$pts->{$id}}) {
			push @a, $_;
		}
		push @pointset, \@a;
	}
	

	# push starting center points (if provided) into the centroids array to serve as cluster seeds
	if ( defined $ctrs ) {
		foreach my $ctr (@$ctrs) {
			my @a = ();
			foreach (@$ctr) {
				push @a, $_;
			}
			push @centroids, \@a;
		}
	}

	# if <k centroids were provided, choose points at random to serve as cluster seeds
	while ( scalar @centroids < $k ) {
		# chose at random without replacement from among existing points in pointset
		my $indx = int rand(scalar @pointset);
		my @a = ();
		foreach (@{$pointset[$indx]}) {
			push @a, $_;
		}
		my $exists = 0;
		foreach (@centroids) {
			if ( d_euclid(\@a, $_) == 0 ) {
				$exists = 1;
				last;
			}
		}
		push(@centroids, \@a) unless $exists == 1;
	}
	
	my $iter = 0;
	while ( $delta > $thresh and $iter < $bugout) {

		$iter++;
		
		if ($debug == 1) {
			print "$iter\tcentroids\t";
			foreach my $pt (@centroids) {
				print join(", ", @$pt) . "\t";
			}
			print "\n";
		}
		
		# reset the clusters array for another round
		@clusters = ();
		for ( my $i=0; $i<$k; $i++ ) {
			$clusters[$i] = [];
		}

		# assign each point in @pointset to the cluster with the closest centroid
		for ( my $i=0; $i<scalar(@pointset); $i++ ) {
			
			my $min;
			my $ctd;
			
			for ( my $j=0; $j<$k; $j++ ) {
				my $d = d_euclid($pointset[$i], $centroids[$j]);
			
				if ( !defined $min or $d < $min ) {
					$min = $d;
					$ctd = $j;
				}
			}
			push @{$clusters[$ctd]}, $i;
		}
 		
		if ($debug == 1) {
			print "$iter\tclusters\t";
			foreach my $arr_of_indices (@clusters) {
				print join(", ", @$arr_of_indices) . "\t";
			}
			print "\n";
		}
		
 		my $delta_sum = 0;
		for ( my $i=0; $i<$k; $i++ ) {
			# calculate a new centroid for each cluster using the center of mass of the points
			my $new_ctr = center_of_mass(\@pointset, $clusters[$i]);
			$delta_sum += d_euclid($new_ctr, $centroids[$i]);
			
			for ( my $j=0; $j<scalar(@$new_ctr); $j++ ) {
				$centroids[$i]->[$j] = $new_ctr->[$j];
			}
		}
		
		# set delta to be mean distance from old to new centroids
		$delta = $delta_sum / $k;

		if ($debug == 1) {
			print "$iter\tdelta\t$delta\n";
		}

	}
	
	# finished moving centroids, so map clusters back to the original ids and return to caller
	my $map = [];
	for ( my $i=0; $i<$k; $i++ ) {
		$map[$i] = [];
		foreach my $pt_indx (@{$clusters[$i]}) {
			push @{$map->[$i]}, $indx2id{$pt_indx};
		}
	}

	return $map;
}



sub d_euclid {
	my ($p, $q) = @_;
	
	my $sum = 0;
	my $d;
	
	if (scalar @$p == 1) {
		$d = abs($p->[0] - $q->[0]);
	} else {
		for ( my $i=0; $i<scalar(@$p); $i++ ) {
			$sum += ( ($p->[$i] - $q->[$i]) * ($p->[$i] - $q->[$i]) );
		}
		$d = sqrt $sum;
	}
	
	return $d;
}


sub center_of_mass {
	my ($pointset_r, $cluster_r) = @_;
	
	return 0 unless scalar @$cluster_r > 0;
	
	my @counts = ();
	my @sums	 = ();
	my @comass = ();
	
	foreach my $indx (@$cluster_r) {
		my $pt = $pointset_r->[$indx];
		for ( my $i=0; $i<scalar(@$pt); $i++ ) {
			$counts[$i] = 0 unless defined $counts[$i];
			$counts[$i] = $counts[$i] + 1;
			
			$sums[$i] = 0 unless defined $sums[$i];
			$sums[$i] = $sums[$i] + $pt->[$i];
		}
	}
	
	for ( my $i=0; $i<scalar(@sums); $i++ ) {
		my $mean = $sums[$i] / $counts[$i];
		push @comass, $mean;
	}
	
	return \@comass;
}


sub validate_input {
	my ( $k, $pts, $ctrs ) = @_;
	return "";
}


1;
