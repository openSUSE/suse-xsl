#!/bin/bash
# Run dapscompare tests with pre-defined parameters and some minor
# intelligence around when building reference images is necessary.
# This tries to take care of a few gotchas when using dapscompare.

function exit_on_error {
    ccecho "error" "ERROR: ${1}" >&2
    exit 1;
}


# To be able to run from the Makefile, we need the real path to this script.
# realpath is a newish part of coreutils. Generally well supported, but has a
# a separate package on Debian/Ubuntu and not available on macOS.
# https://stackoverflow.com/questions/4774054
MYPATH=$(dirname "$(realpath -s "$0")")
TESTPATH="$MYPATH/dapscompare-tests"

# v >0.2.1 = dapscompare; v >0.3 = dapscmp
BINARY=$(which dapscompare 2> /dev/null || which dapscmp 2> /dev/null)
VERSION=0
if [[ ! "$BINARY" ]]; then
  exit_on_error "dapscompare is not installed!"
fi
VERSION="$($BINARY --help | grep -i -m1 '^version:' | awk '{print $3}')"

TESTCOMMAND='compare'
# The check whether we need to do a reference run is by no means perfect. It
# only checks if there are any image directories (at all) and does not bother
# with anything more.
if [[ $1 == 'reference' ]] || [[ $(ls dapscompare-tests/*/dapscompare-reference 2> /dev/null | wc -l) == 0 ]]; then
  echo "Will do a reference run."
  echo "This means you must not have made any stylesheet changes yet."
  echo "Continue? [y/(n)]"
  read DECISION
  if [[ ! $DECISION == 'y' ]] && [[ ! $DECISION == 'yes' ]]; then
    echo "If you have already made stylesheet changes, revert/stash them, then run ${0} again."
    exit
  fi
  TESTCOMMAND='reference'
  shift
  # For the moment, lets purge all existing reference images. dapscompare might
  # in the future take better care of not running into an inconsistent state,
  # so far it does not do much to avoid that.
  echo -n "Purging old reference images..."
  cd $TESTPATH
  $BINARY clean > /dev/null
  echo "Done"
else
  echo "Will do a comparison run."
  echo "This assumes you have already made your stylesheet changes."
fi

if [[ $1 ]]; then
  exit_on_error "Unrecognized option $1!"
fi

EXTRAARGS=
# reference
if [[ -f "$MYPATH/dapscompare.conf" && 'reference' ]]; then
  EXTRAARGS=$(cat "$MYPATH/dapscompare.conf")
# comparison + older version
elif [[ $VERSION == '0.2.0' ]] || [[ $VERSION == '0.2.1' ]]; then
  EXTRAARGS="--load-config"
fi

echo -n "Making the stylesheets..."
cd "$MYPATH/.." && make > /dev/null
echo "Done"


cd $TESTPATH

echo -n "Validating DC files..."
for DCFILE in */DC-*; do
  daps -d ${DCFILE} validate > /dev/null || exit_on_error "DC file $DCFILE is not valid!"
done
echo "Done"

$BINARY $TESTCOMMAND $EXTRAARGS

# optipng can reduce the size of HTML-generated images dramatically (often
# around 30%), images generated from PDFs are usually already (almost)
# optimized. However, optipng is irrelevant for now, since there is currently
# no use in storing these images on the server, as font rendering differences
# mean that they are not particularly comparable across machines.

#if [[ $TESTCOMMAND == 'reference' ]]; then
#  echo -n "Optimizing with optipng..."
#  optipng */dapscompare-reference/*/*.png > /dev/null 2> /dev/null
#  echo "Done"
#fi

