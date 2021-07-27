#!/bin/sh

set -e # exit on any error

BOOTSTRAP_PREFIX=$PWD/bootstrap-build

if [ "$OS" = "windows" ]; then
    # IDRIS_PREFIX is only used to build BOOTSTRAP_IDRIS_PATH
    IDRIS_PREFIX=$(cygpath -m "$BOOTSTRAP_PREFIX")
    SEP=";"
else
    IDRIS_PREFIX=$BOOTSTRAP_PREFIX
    SEP=":"
fi

IDRIS2_CG="${IDRIS2_CG-"chez"}"

BOOT_PATH_BASE=$IDRIS_PREFIX/idris2-$IDRIS2_VERSION
BOOTSTRAP_IDRIS_PATH="$BOOT_PATH_BASE/prelude$SEP	$BOOT_PATH_BASE/base$SEP	$BOOT_PATH_BASE/contrib$SEP	$BOOT_PATH_BASE/network	$BOOT_PATH_BASE/test"

# BOOTSTRAP_PREFIX must be the "clean" build root, without cygpath -m
# Otherwise, we get 'git: Bad address'
echo "$BOOTSTRAP_PREFIX"
DYLIB_PATH="$BOOTSTRAP_PREFIX/lib"

$MAKE libs IDRIS2_CG="$IDRIS2_CG" LD_LIBRARY_PATH="$DYLIB_PATH" \
    PREFIX="$BOOTSTRAP_PREFIX" SCHEME="$SCHEME"
$MAKE install IDRIS2_CG="$IDRIS2_CG" LD_LIBRARY_PATH="$DYLIB_PATH" \
    PREFIX="$BOOTSTRAP_PREFIX" SCHEME="$SCHEME"

# Now rebuild everything properly
$MAKE clean-libs BOOTSTRAP_IDRIS="$BOOTSTRAP_PREFIX/bin/idris2"
$MAKE all BOOTSTRAP_IDRIS="$BOOTSTRAP_PREFIX/bin/idris2" IDRIS2_CG="$IDRIS2_CG" \
    IDRIS2_PATH="$BOOTSTRAP_IDRIS_PATH" LD_LIBRARY_PATH="$DYLIB_PATH" \
    SCHEME="$SCHEME"
