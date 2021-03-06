#!/bin/sh
# ----------------------------------------------------------------------------

# The name of the Docker image created by this process.  (Probably
# doesn't matter, so long as it doesn't clobber another image you care
# about.)
DOCKER_IMAGE_NAME="cmpilato/subversion-dist"

# The branch string from the Apache Subversion repository that you're
# building.  This value is appended to the repository base URL, and
# should be "trunk", "branches/1.12.x", "tags/1.13.1", ...
SUBVERSION_BRANCH="tags/1.14.0"

# The "name" of the release.  At this time, this needs to at least
# include the MAJOR and MINOR versions of the Subversion branch you
# aim to build.  (See the patch generated by 'make-svn-release.sh',
# which requires the version string in its name, because Subversion's
# release.py ... ugh.)
SUBVERSION_BUILD_NAME="subversion-1.14.0"

# Set this to "2" or "3".
SUBVERSION_PYTHON_VERSION="2"

# ----------------------------------------------------------------------------

echo "*** Creating Docker image ${DOCKER_IMAGE_NAME} ***"
docker build . -f Dockerfile -t ${DOCKER_IMAGE_NAME}:latest

echo "*** Running the Subversion release build process ***"
docker run -v `pwd`/target:/app/target \
       --env SUBVERSION_BRANCH=${SUBVERSION_BRANCH} \
       --env SUBVERSION_BUILD_NAME=${SUBVERSION_BUILD_NAME} \
       --env SUBVERSION_PYTHON_VERSION=${SUBVERSION_PYTHON_VERSION} \
       ${DOCKER_IMAGE_NAME}:latest \
       bash -c "./make-svn-release.sh 2>&1 | tee ./target/build.log"

echo "*** All done!  What did we make? ***"
ls -l target/
