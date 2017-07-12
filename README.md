# synteBLAST v0.1
**BLAST-based, synteny-aware (protein) sequence searching.**

## Attribution
*synteBLAST* was written by [Timothy Driscoll](http://www.driscollMML.com/) at West Virginia University, Morgantown, WV USA. The concept for a synteny-aware search algorithm arose from discussions and work with numerous other researchers, most notably: Joseph J. Gillespie, University of Maryland; and Victoria Verhoeve, West Virginia University.

## Description
*synteBLAST* is a search pipeline designed to find co-linear (syntenic) blocks of genes that are similar to a query block in both **sequence** and **arrangement on the genome**.

Prokaryotes often utilize blocks of cotranscribed genes called operons to carry out similar functional tasks. The texbook example of operons (literally) is the *lac* operon of *Escherichia coli*.

## Installation
*synteBLAST* is built on Perl and Bash. It requires no special installation (but see **Dependencies** below).

1. Download the latest version of *synteBLAST* from github.
2. Unzip the downloaded file, and move the resulting folder to a convenient location on your computer.
3. Install the dependencies listed below.

## Dependencies
*synteBLAST* requires an Internet connection, a working shell (preferably Bash), and the following packages to function properly. Some simple UNIX knowledge will be helpful.

### [blast+ v2.6.0+](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download)

1. [Download](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download) the latest version of blast+ for your operating system.
2. Decompress the downloaded file (usually by double-clicking on it).
3. Move the resulting folder (e.g. *ncbi-blast-2.6.0+*) to a convenient location on your computer.
4. Open the file ~/.bashrc in your favorite text editor, and add the following line to the very bottom of that file: `export PATH=$PATH:PATH-TO-BLAST/ncbi-blast-2.6.0+/bin` (replace PATH-TO-BLAST with the absolute path to the blast directory from Step 3). Save and close the file. For a more comprehensive (and mildly confusing) explanation about modifying your PATH variable, [see here](https://askubuntu.com/questions/3744/how-do-i-modify-my-path-so-that-the-changes-are-available-in-every-terminal-sess).
5. Quit and relaunch terminal, if open. Alternatively, type `source ~/.bashrc` into any open terminals to make sure the changes from step 4 take effect.
6. Use `blastp -h` to check what version of BLAST is installed on your machine.


### [Perl v5.22.0](https://www.perl.org/get.html)

1. Use `perl -v` to check what version of Perl is active on your machine.

Perl is installed by default on almost all Linux and OS X systems. If you have no Perl on your machine, the easiest way to install it is using a package manager. Linux has many options: apt, rpm, yum are fairly popular. For macOS, we recommend [homebrew](https://brew.sh/). **Installing and compiling Perl from source is highly discouraged, and we can not provide technical assistance in this regard.**

### [Algorithim::NeedlemanWunsch v0.03](http://search.cpan.org/~vbar/Algorithm-NeedlemanWunsch-0.03/lib/Algorithm/NeedlemanWunsch.pm)

NeedlemanWunsch is a Perl module that can be accessed via CPAN, the central Perl repository. There are many ways to do this. If you have a system installation of Perl (likely), and sudo or Admin access (possibly), this is probably easiest:

1. `sudo perl -MCPAN -e shell`
2. `install Algorithim::NeedlemanWunsch`

If you have installed Perl yourself (for example, using a package manager like **homebrew**), or your Perl is not system-level (usually the case on remote servers), you can follow the same steps but probably don't need to sudo. Other options for installing Perl modules are [numerous](http://www.cpan.org/modules/INSTALL.html) [and](https://perlmaven.com/how-to-install-a-perl-module-from-cpan) [plentiful](http://www.thegeekstuff.com/2008/09/how-to-install-perl-modules-manually-and-using-cpan-command/) on the Internet.


## Using synteBLAST
Run the *synteBLAST* wrapper shell script, passing it a fasta file that contains the co-linear block to use as query:

`synteblast.sh -i INPUT_BLOCK.faa -o OUTPUT_BASE`

The wrapper script accepts a number of optional parameters that allow you to customize it further:

> ##### -i \<*filepath*\>
> REQUIRED
> Path to a **protein fasta file** containing the ordered query sequences.

> ##### -o \<*string*\>
> REQUIRED
> String to use as the prefix to **project output** file names.

> ##### -e \<*float*\>
> Value to use as the **maximum e-value** for sequence matches. Used during the initial remote blast query. (0.001)

> ##### -p \<*float*\>
> Value (0-100) to use as the **minimum percent identity** between match and query. Used during the thresholding step. (40)

> ##### -c \<*float*\>
> Value (0-100) to use as the **minimum percent coverage** across the query. Used during the thresholding step. (60)

> ##### -f \<*string*\>
> **Entrez string** to filter the initial remote blast query. (bacteria[orgn] AND "srcdb refseq"[Properties])

> ##### -m \<*string*\>
> **Scoring matrix** to use for the initial remote blast query. (BLOSUM45)

> ##### -F
> Set this flag to **force** synteBLAST to write over an existing blast file. By default, the initial blast query will not be run if an output file already exists, since this is a rate-limiting step.



## Release log
###### synteblast v0.1
*Release date:* 2017-07-10
*Description:* **synteBLAST v0.1** is the first fully-functional, soup-to-nuts release. It includes a rudimentary scoring mechanism to rank taxa first based on the proportion of orthologs present (occupancy, or U), and then based on Needleman-Wunsch pairwise alignment of the complete block to the reference (co-linearity, or C). The scoring matrix for this alignment is 1 for a match, -1 for a mismatch, and -2 for a gap.
*Known limitations:* Scoring mechanism does not take into account distances between genes in a block. 


## License
*synteBLAST* is released under the GNU GPL v3 license. Please see the file LICENSE included in the top-level directory of every release.
