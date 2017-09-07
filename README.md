# cellranger_clean
10x distributes a tarball of code and dependencies for their Cell Ranger software suite. That
tarball has a [non-free license](https://support.10xgenomics.com/docs/license). But 10x also
makes the source for Cell Ranger available on github, licensed with AGPL.

This repo is a docker image that contains the compiled, free Cell Ranger code and can be used
in place of the non-free Cell Ranger tarball.
