# RELEASE LOG
### synteBLAST v1.0
[https://github.com/driscollmml/synteblast](https://github.com/driscollmml/synteblast)

## VERSION 1.0
**RELEASE DATE:** December ??, 2017
**DESCRIPTION:** synteblast v1.0 is the first fully-functional, soup-to-nuts release of synteBLAST. It includes a rudimentary scoring mechanism to rank taxa first based on the proportion of orthologs present (occupancy, or U), and then based on Needleman-Wunsch pairwise alignment of the complete block to the reference (co-linearity, or C). The scoring matrix for this alignment is 1 for a match, -1 for a mismatch, and -2 for a gap.
**KNOWN LIMITATIONS:** Scoring mechanism does not take into account distances between genes in a block.

