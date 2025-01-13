# FreeSurfer in Docker Debian

- https://github.com/freesurfer/freesurfer
- https://surfer.nmr.mgh.harvard.edu/fswiki/BuildGuide
- https://surfer.nmr.mgh.harvard.edu/fswiki/BuildRequirements

#### Downloading

- git clone git@github.com:freesurfer/freesurfer.git
- cd freesurfer
- git remote add datasrc https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/repo/annex.git
- git fetch datasrc
- git config annex.dbdir /Users/morpheous/TMP2/AnnexSQlite
- git-annex init
- git-annex get .

#### Compiler Problems

- written in c++11 , c++14 , c++17 , c++20 ??
- ITK needs one thing , VTK needs another , freesurfer needs 17 ?
- lots of cleanup
- then building non-minimal
- now we might be able to get the alpine version to build.
- need a family of compilers

#### License ?

- https://surfer.nmr.mgh.harvard.edu/registration.html
- save the lines below to a file named license.txt in the directory pointed to by the $FREESURFER_HOME environment variable set during the software install