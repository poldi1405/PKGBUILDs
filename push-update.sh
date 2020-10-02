#!/bin/bash

PKGNAME=$(basename $(pwd))

echo "Updating $PKGNAME…"

if [ $(git status --short | wc -l) == 0 ]; then
	echo "Nothing changed. What am I supposed to update?"
	exit 1
fi

echo "verifying PKGBUILD…"
stat=$(namcap -i PKGBUILD | grep " E: " | wc -l)
if [ $stat != 0 ]; then
	namcap -i PKGBUILD
	echo "there are issues with your PKGBUILD."
	exit 1
fi

echo "regenerating SRCINFO…"
mksrcinfo PKGBUILD

if [ $? != 0 ]; then
	echo "An error occured while executing 'mksrcinfo'. Check above for output"
	exit 1
fi

version=$(grep "pkgver = " < .SRCINFO | sed 's/\tpkgver = //')

echo "uploading to AUR with commit-message 'updated package to $version'"
echo "is this message alright? (^C to abort)"
read

git add * .SRCINFO
git commit -m "updated package to $version"
git push origin HEAD:master
git checkout master
git pull

echo "updating container-repository…"
cd ..
git add $PKGNAME
git commit -m "updated $PKGNAME to $version"
git push
