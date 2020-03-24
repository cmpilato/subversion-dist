subversion-dist
===============

Docker-based Apache Subversion® release tarball assembly


Building a Subversion release
-----------------------------

In theory, all that's needed to build an Apache Subversion® release
tarball is to fiddle with the environment variables at the top of
`docker-build.sh`, and then run that script.  The script will created
a Docker image and then run, inside that image, Subversion's own
release distribution process.
