# INSTALL INSTRUCTIONS

### synteBLAST v0.1
[https://github.com/driscollmml/synteblast](https://github.com/driscollmml/synteblast)


## Installation
`synteblast` is built on Perl and Bash. It requires no special compilation or installation (but see **Dependencies** below).

1. Download or checkout the latest version of `synteblast` from [github](https://github.com/driscollmml/synteblast).
2. Unzip the downloaded file and move the resulting folder to a convenient location on your computer. If you checked out the repository instead, skip this step.
3. For ease of use, add the **synteblast/sbin/** folder to your PATH variable. Do not remove or re-organize the files in **sbin/**.
4. Install the dependencies listed below.

## Dependencies
`synteblast` requires an Internet connection, a working shell (preferably Bash), and the following packages to function properly. Some simple UNIX knowledge will be helpful.

### [blast+ v2.6.0+](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download)

1. [Download](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download) the latest version of blast+ for your operating system.
2. Decompress the downloaded file (usually by double-clicking on it).
3. Move the resulting folder (e.g. *ncbi-blast-2.6.0/+*) to a convenient location on your computer.
4. Open the file *~/.bashrc* in your favorite text editor, and add the following line to the very bottom of that file: `export PATH=$PATH:PATH-TO-BLAST/ncbi-blast-2.6.0+/bin` (replace PATH-TO-BLAST with the absolute path to the blast directory from Step 3). Save and close the file. For a more comprehensive (and mildly confusing) explanation about modifying your PATH variable, [see here](https://askubuntu.com/questions/3744/how-do-i-modify-my-path-so-that-the-changes-are-available-in-every-terminal-sess).
5. Quit and relaunch terminal, if open. Alternatively, type `source ~/.bashrc` into any open terminals to make sure the changes from step 4 take effect.
6. Use `blastp -h` to check what version of blast+ is installed on your machine; this also verifies it is installed and accessible.


### [Perl v5.22.0](https://www.perl.org/get.html)

1. Use `perl -v` to check what version of Perl is active on your machine.

Perl is installed by default on almost all Linux and OS X systems. If you have no Perl on your machine, the easiest way to install it is using a package manager. Linux has many options: apt, rpm, yum are fairly popular. For macOS, we recommend [homebrew](https://brew.sh/). **Installing and compiling Perl from source is highly discouraged. We can not provide technical assistance in this regard.**

### [Algorithim::NeedlemanWunsch v0.03](http://search.cpan.org/~vbar/Algorithm-NeedlemanWunsch-0.03/lib/Algorithm/NeedlemanWunsch.pm)

NeedlemanWunsch is a Perl module that can be accessed via CPAN, the central Perl repository. There are many ways to do this. If you have a system installation of Perl (likely), and sudo or Admin access (possibly), this is probably easiest:

1. `sudo perl -MCPAN -e shell`
2. `install Algorithim::NeedlemanWunsch`

If you have installed Perl yourself (for example, using a package manager like **homebrew**), or your Perl is not system-level (usually the case on remote servers), you can follow the same steps but probably don't need to sudo. Other options for installing Perl modules are [numerous](http://www.cpan.org/modules/INSTALL.html) [and](https://perlmaven.com/how-to-install-a-perl-module-from-cpan) [plentiful](http://www.thegeekstuff.com/2008/09/how-to-install-perl-modules-manually-and-using-cpan-command/) on the Internet.

### [File::Basename v2.85](https://metacpan.org/pod/File::Basename)

File::Basename is a Perl module like Algorithim::NeedlemanWunsch, and can be installed in similar fashion.

