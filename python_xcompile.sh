#!/bin/bash

TARGET_HOST="arm-linux-gnueabihf"
ROOT_FILESYSTEM="/usr/arm-linux-gnueabi/"
BUILD_HOST="x86_64-linux-gnu" # find out with uname -m
WORKING_DIRECTORY="python_xcompile"
INSTALL_DIRECTORY="$WORKING_DIRECTORY/_install"
PYTHON_VERSION="2.7.5"


# Preparing compile environment
export RFS="$ROOT_FILESYSTEM"
PREFIX=$(readlink --no-newline --canonicalize "$INSTALL_DIRECTORY")
mkdir -p "$WORKING_DIRECTORY"
mkdir -p "$PREFIX"

# Step 1 - Downloading Python and extracting
cd $WORKING_DIRECTORY
wget -c http://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.bz2
rm -rf Python-$PYTHON_VERSION
tar -jxf Python-$PYTHON_VERSION.tar.bz2
cd Python-$PYTHON_VERSION

# Step 1 - Compile programs used by build System during build
./configure
make python Parser/pgen
mv python python_for_build
mv Parser/pgen Parser/pgen_for_build

# Step 2 - Patch and Cross-Compile
patch -p3 --input ../files/Python-$PYTHON_VERSION-xcompile2.patch
make distclean
./configure --host=$TARGET_HOST --build=$BUILD_HOST --prefix=$PREFIX \
    --disable-ipv6 ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no \
    ac_cv_have_long_long_format=yes
make
make install
