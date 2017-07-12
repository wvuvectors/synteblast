#! /bin/bash

#
# synteblast master control
#

while getopts ":i:o:g:re:p:c:f:m:F" opt; do
	case $opt in
		h)
			echo "help not available."
			exit 1
			;;
		i)
			# REQUIRED
			# protein fasta file containing the ordered query sequences
			query=$OPTARG
			;;
		o)
			# REQUIRED
			# output name base
			out=$OPTARG
			;;
		g)
			# REQUIRED if -r is set
			# protein fasta file containing all proteins from the query genome
			genome=$OPTARG
			;;
		r)
			# run in reciprical best blast mode
			rbb=1
			;;
		e)
			# e-value threhold (max) for initial blastp run
			t_evalue=$OPTARG
			;;
		p)
			# percent identity threhold (min) for initial blastp run
			t_pctid=$OPTARG
			;;
		c)
			# query coverage threhold (min) for initial blastp run
			t_qcovs=$OPTARG
			;;
		f)
			# entrez query string to filter the results of the initial blastp run
			entrez_query=$OPTARG
			;;
		F)
			# always force remote blast to run, even if the output file already exists
			force=1
			;;
		m)
			# scoring matrix name for initial blastp run
			matrix=$OPTARG
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 1
			;;
	esac
done


if [ -z "$query" ]; then
	echo "FATAL : A protein fasta file to use as input query is REQUIRED [-i <filepath>]."
	exit 1
fi

if [ -z "$out" ]; then
	echo "FATAL : An output name is REQUIRED [-o <string>]."
	exit 1
fi

if [ -z "$rbb" ]; then
	rbb=0
fi

if [ $rbb -eq 1 -a -z "$genome" ]; then
	echo "FATAL : Reciprical best blast (RBB) mode is enabled (-r). A protein fasta file containing all proteins in the query genome is REQUIRED [-g <filepath>]."
	exit 1
fi

if [ -z "$t_evalue" ]; then
	t_evalue=0.001
fi

if [ -z "$t_pctid" ]; then
	t_pctid=40
fi

if [ -z "$t_qcovs" ]; then
	t_qcovs=60
fi

if [ -z "$t_matches" ]; then
	t_matches=1000
fi

if [ -z "$entrez_query" ]; then
	entrez_query="bacteria[orgn] AND \\\"srcdb refseq\\\"[Properties]"
fi

if [ -z "$matrix" ]; then
	matrix="BLOSUM45"
fi

if [ -z "$force" ]; then
	force=0
fi



if [ "$force" == '0' ] && [ -f "$out.0.blastp" ];then
	echo "WARN  : 01 A blastp output file ($out.0.blastp) already exists in the current working directory."
	echo "WARN  : 02 Since remote blast is a time-intensive process, the existing file will be used."
	echo "WARN  : 03 To change this behavior, and always run the remote blast, re-run synteblast with the -F (force) flag set."
else
	exit
	# blastp the input proteins against nr using input parameters for eval, %ID, %align, and max_hits
	echo "time blastp \
-task blastp \
-remote \
-db nr \
-outfmt '6 qseqid qlen slen sseqid evalue pident qcovs' \
-query \"$query\" \
-entrez_query \"$entrez_query\" \
-evalue $t_evalue \
-matrix \"$matrix\" \
-out \"$out.0.blastp\" \
-max_target_seqs $t_matches \
"

	time blastp \
-task blastp \
-remote \
-db nr \
-outfmt '6 qseqid qlen slen sseqid evalue pident qcovs' \
-query "$query" \
-entrez_query "$entrez_query" \
-evalue $t_evalue \
-matrix "$matrix" \
-out "$out.0.blastp" \
-max_target_seqs $t_matches

fi


# remove any hits that fall below the %id and qcovs thresholds
synteblast_thresh.pl -p $t_pctid -c $t_qcovs < "$out.0.blastp" > "$out.1.threshed"

# add taxonomy info to threshed hits
synteblast_taxify.pl < "$out.1.threshed" > "$out.2.taxed"
mv "ipg.tmp" "$out.ipg.tmp"

# score and sort hits
synteblast_rank.pl -i "$query" < "$out.2.taxed" > "$out.3.ranked"

