# RELEASE LOG
### synteBLAST v0.1
[https://github.com/driscollmml/synteblast](https://github.com/driscollmml/synteblast)

## VERSION 0.1
**RELEASE DATE:** August ??, 2017
**DESCRIPTION:** synteblast v0.1 is the first fully-functional, soup-to-nuts release. It includes a rudimentary scoring mechanism to rank taxa first based on the proportion of orthologs present (occupancy, or U), and then based on Needleman-Wunsch pairwise alignment of the complete block to the reference (co-linearity, or C). The scoring matrix for this alignment is 1 for a match, -1 for a mismatch, and -2 for a gap.
**KNOWN LIMITATIONS:** Scoring mechanism does not take into account distances between genes in a block.

