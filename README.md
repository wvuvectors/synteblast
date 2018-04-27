# synteBLAST v1.0
**BLAST-based, synteny-aware (protein) sequence searching.**


## Description
`synteBLAST` is a search pipeline designed to find co-linear (syntenic) blocks of genes that are similar to a query block in both **sequence** and **arrangement on the genome**.

Prokaryotes often utilize blocks of cotranscribed genes called operons to carry out similar functional tasks. A texbook example of operons (literally) is the *lac* operon of *Escherichia coli*.


## Attribution
`synteBLAST` was written by [Timothy Driscoll](http://www.driscollMML.com/) at West Virginia University, Morgantown, WV USA. The concept for a synteny-aware search algorithm arose from discussions and work with numerous other researchers, most notably Joseph J. Gillespie (University of Maryland) and Victoria Verhoeve (West Virginia University).


## Using synteBLAST

###### QuickStart

Run the `synteblast` wrapper shell script, passing it a fasta file that contains the sequences for the colinear block, in the desired order, to use as query:

`synteblast -i INPUT_BLOCK.faa`

`synteblast` will produce four output files, all with the prefix *synteblast_out*. The final results are written to a file called *synteblast_out.3.ranked*; this is a tab-delimited file containing all matches to the query block in order (best matches at the top). This file can be imported or copied directly into an app like Excel.

###### CustomStart

`synteblast` also accepts several optional arguments that you can use to customize your results. A complete list can be found by running `synteblast -h`.

`synteblast -i INPUT_BLOCK.faa [-o OUTBASE] [-e FLOAT] [-p FLOAT] [-c FLOAT] [-f STRING] [-m STRING] [-F]`

> ##### -i \<*filepath*\>
> REQUIRED
> Path to a **protein fasta file** containing the ordered query sequences.


> ##### -o \<*string*\>
> OPTIONAL
> String to use as the prefix to **project output** file names.

> ##### -e \<*float*\>
> OPTIONAL
> Value to use as the **maximum e-value** for sequence matches. Used during the initial remote blast query. [default: 0.001]

> ##### -p \<*float*\>
> OPTIONAL
> Value (0-100) to use as the **minimum percent identity** between match and query. Used during the thresholding step. [default: 40]

> ##### -c \<*float*\>
> OPTIONAL
> Value (0-100) to use as the **minimum percent coverage** across the query. Used during the thresholding step. [default: 60]

> ##### -f \<*string*\>
> OPTIONAL
> **Entrez string** to filter the initial remote blast query. [default: bacteria[orgn] AND "srcdb refseq"[Properties]]

> ##### -m \<*string*\>
> OPTIONAL
> **Scoring matrix** to use for the initial remote blast query. [default: BLOSUM45]

> ##### -F
> OPTIONAL
> Set this flag to **force** synteblast to write over an existing blast file. By default, the initial blast query will not be run if an output file of the same name already exists, since this is almost always a very time-consuming step. [default: false]


## License
*synteBLAST* is released under the GNU GPL v3 license. Please see the file LICENSE included in the top-level **synteblast** directory of every release.
