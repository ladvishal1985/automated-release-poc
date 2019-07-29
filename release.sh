#!/usr/bin/env bash

# Assuming you have a master and dev branch, and that you make new
# release branches named as the version they correspond to, e.g. 1.0.3
# Usage: ./release.sh 1.0.3 develop master

# Get version argument and verify
version=$1 
src=$2
targ=$3

# Get version from package.json
#PKG_VERSION=$(node -pe "require('./package.json').version")

if [ -z "$version" ] || [ -z "$src" ] || [ -z "$targ" ]; then
  echo "Please specify appropriate version, source branch and target branch"
  exit
fi


# Output
echo "Releasing version $version merging from $src -> $targ"
echo "-------------------------------------------------------------------------"


# Get current branch and checkout if needed
# branch=$(git symbolic-ref --short -q HEAD)
# if [ "$branch" != "$version" ]; then
#  git checkout $version
# fi

# Ensure working directory in version branch clean
git update-index -q --refresh
if ! git diff-index --quiet HEAD --; then
  echo "Working directory not clean, please commit your changes first"
  exit
fi

# Checkout master branch and merge version branch into master
git checkout $targ
git merge $src --no-ff --no-edit

# Run version script, creating a version tag, and push commit and tags to remote
npm version $version
git push
git push --tags

# Checkout dev branch and merge master into dev (to ensure we have the version)
git checkout $src
git merge $targ --no-ff --no-edit
git push


# Success
echo "-------------------------------------------------------------------------"
echo "Release $version complete"