#!/bin/bash
# Sets the version number of SUSE XSL Stylesheets to $1.

NEWVERSION="$1"

if [[ -z ${1} ]]; then
  echo "(meh) Need a version number as an argument."
  exit
elif [[ $(echo $NEWVERSION | sed -r 's/^[.0-9]+//') ]]; then
  echo "(meh) Version number must consist only of numbers and . characters."
  echo "Your version number had the following extra characters: $(echo $NEWVERSION | sed -r 's/^[.0-9]+//')"
  exit
fi

sed -i -r "s/^(Version: +)[.0-9]+$/\1$NEWVERSION/" packaging/suse-xsl-stylesheets.spec
sed -i -r "s/^(VERSION +:= )[.0-9]+$/\1$NEWVERSION/" Makefile
sed -i -r "s/^(SUSE XSL Stylesheets )[.0-9]+$/\1$NEWVERSION/" README.adoc
echo -e "Fixed up version in spec file, Makefile, and README.\nDo not forget to document the new version in the ChangeLog file."
