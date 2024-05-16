#!/bin/bash
#
# Create an archive of project directory for OBS
# 
# Author: Tom Schraitle, 2022-2023


set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

ME="${0##*/}"
NAME="suse-xsl"
OUTDIR="/tmp"
SUFFIX=".tar.gz"
FROM="HEAD"

function exit_on_error {
    echo "ERROR: ${1}" >&2
    exit 1;
}

function usage {
    cat << EOF
Create archive of current repo 

SYNOPSIS
  $ME [OPTIONS] [VERSION]
  $ME -h|--help

OPTIONS
  -h, --help        Output this help text.
  --outdir=OUTDIR   Store archive in OUTDIR (default ${OUTDIR@Q})
  -f FROM, --from=FROM
                    The tree or commit to produce an archive for
                    (default ${FROM@Q})

ARGUMENTS
  VERSION           Use this version to create the archive
                    If omitted, the version is retrieved through "git describe"
                    Any "v" prefix is removed.

EXAMPLES:
    1. $ME
       creates an archive and stores it under $OUTDIR

    2. $ME --outdir=/local/repo
       creates an archive and stores it under /local/repo

    3. $ME v3.0.0
       creates an archive /tmp/$NAME-3.0.0.tar.bz2
EOF
}

# -- CLI parsing
ARGS=$(getopt -o h,f: -l help,from:,outdir: -n "$ME" -- "$@")
eval set -- "$ARGS"
while true; do
  case "$1" in
    --help|-h)
        usage
        exit 0
        shift
        ;;
    -f|--from)
        FROM="$2"
        shift 2
        ;;
    --outdir)
        OUTDIR="$2"
        if [ ! -d "$OUTDIR" ]; then
           mkdir -p "$OUTDIR"
        fi
        shift 2
        ;;
    --) shift ; break ;;
    *) exit_on_error "Wrong parameter: $1" ;;
  esac
done

# Remove last slash and expand ~ with $HOME
OUTDIR=${OUTDIR%*/}
OUTDIR=${OUTDIR/#\~/$HOME}

# Get version from git: 
VERSION=$(git describe)

# Overwrite VERSION with first argument
if [ "$#" -ne 0 ]; then
   VERSION="$1"
fi

# Remove "v" prefix:
VERSION=${VERSION#v*}
FILE="${OUTDIR}/${NAME}-${VERSION}${SUFFIX}"
echo "Generating version ${FILE@Q}..."

git archive --worktree-attributes --format=${SUFFIX#.*} \
    --prefix="suse-xsl-${VERSION}/" \
    --output="${FILE}" \
    "$FROM"
