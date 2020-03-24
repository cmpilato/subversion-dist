#!/bin/sh

set -x

if [ -z SUBVERSION_BRANCH ]; then
    echo "ERROR: Missing SUBVERSION_BRANCH environment variable." 1>&2
    exit 1
else
    REPOS_URL=https://svn.apache.org/repos/asf/subversion/${SUBVERSION_BRANCH}
fi
if [ -z SUBVERSION_BUILD_NAME ]; then
    echo "ERROR: Missing SUBVERSION_BUILD_NAME environment variable." 1>&2
    exit 1
fi

# Checking out Subversion source code
SUBVERSION_WORK_DIR="subversion.dist"
if [ -d ${SUBVERSION_WORK_DIR} ]; then
    rm -rf ${SUBVERSION_WORK_DIR}
fi
svn checkout ${REPOS_URL} ${SUBVERSION_WORK_DIR}

# Applying custom patches (if any)
for PATCH in /app/patches/*; do
    if [ $PATCH != "/app/patches/README" ]; then
        (cd ${SUBVERSION_WORK_DIR}; patch -p0 < ${PATCH})
    fi
done

# Fetching the checked-out revision
cd ${SUBVERSION_WORK_DIR}
SVN_REVISION=`svn info --show-item=revision -- ${REPOS_URL}`

# Preparing build environment
cd tools/dist
./release.py --clean --verbose --branch ${SUBVERSION_BRANCH} \
             build-env ${SUBVERSION_BUILD_NAME}

# Building ${SUBVERSION_BUILD_NAME} ${SVN_REVISION}
export SWIG_PY_OPTS="-python -py3 -nofastunpack -modern"
./release.py --verbose --branch ${SUBVERSION_BRANCH} \
             roll ${SUBVERSION_BUILD_NAME} ${SVN_REVISION}

# Copying build artifacts into target folder
cp deploy/* /app/target

# Removing working folder
if [ -d ${SUBVERSION_WORK_DIR} ]; then
    rm -rf ${SUBVERSION_WORK_DIR}
fi
