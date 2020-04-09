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

# Make a directory for patches, and create patch required to make
# Python2 SWIG generation possible.
if [ -d ${APP_HOME}/patches ]; then
    rm -rf ${APP_HOME}/patches
fi
mkdir ${APP_HOME}/patches
cat <<EOF > ${APP_HOME}/patches/${SUBVERSION_BUILD_NAME}.gen_make.patch
Index: build/generator/gen_make.py
===================================================================
--- build/generator/gen_make.py	(revision 1876320)
+++ build/generator/gen_make.py	(working copy)
@@ -511,7 +513,9 @@
     standalone.write('top_srcdir = .\n')
     standalone.write('top_builddir = .\n')
     standalone.write('SWIG = swig\n')
-    standalone.write('SWIG_PY_OPTS = -python -py3 -nofastunpack -modern\n')
+    swig_py_opts = os.environ.get('SWIG_PY_OPTS',
+                                  '-python -py3 -nofastunpack -modern')
+    standalone.write('SWIG_PY_OPTS = %s\n' % (swig_py_opts))
     standalone.write('PYTHON = ' + sys.executable + '\n')
     standalone.write('\n')
     standalone.write(open("build-outputs.mk","r").read())
EOF

# Checking out Subversion source code
SUBVERSION_WORK_DIR="subversion.dist"
if [ -d ${SUBVERSION_WORK_DIR} ]; then
    rm -rf ${SUBVERSION_WORK_DIR}
fi
svn checkout ${REPOS_URL} ${SUBVERSION_WORK_DIR}

# Fetching the checked-out revision
cd ${SUBVERSION_WORK_DIR}
SVN_REVISION=`svn info --show-item=revision -- ${REPOS_URL}`


# Building ${SUBVERSION_BUILD_NAME} ${SVN_REVISION}
cd tools/dist
if [ ${SUBVERSION_PYTHON_VERSION} = "2" ]; then
    export SWIG_PY_OPTS="-python -classic"
else
    export SWIG_PY_OPTS="-python -py3 -nofastunpack -modern"
fi
./release.py --clean --verbose --branch ${SUBVERSION_BRANCH} \
             build-env ${SUBVERSION_BUILD_NAME}
./release.py --verbose --branch ${SUBVERSION_BRANCH} \
             roll --patches ${APP_HOME}/patches \
             ${SUBVERSION_BUILD_NAME} ${SVN_REVISION} \

# Copying build artifacts into target folder
cp deploy/* ${APP_HOME}/target

# Removing working folder
if [ -d ${SUBVERSION_WORK_DIR} ]; then
    rm -rf ${SUBVERSION_WORK_DIR}
fi
