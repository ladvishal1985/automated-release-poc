#!/usr/bin/env bash

# Assuming you have a master and test branch, and that you make new
# tag on master branch the script will do merge from develop to master 
# push a new tag named as the version they correspond to, e.g. 1.0.3
# Usage: ./release.sh 1.0.3 test master

# Get version argument and verify
version=$1 
src=$2
targ=$3



if [ -z "$version" ] || [ -z "$src" ] || [ -z "$targ" ]; then
  echo "Please specify appropriate version, source branch and target branch"
  exit
fi


# Output
# Get version from package.json
PKG_VERSION=$(node -pe "require('./package.json').version")
echo "Current Application version is $PKG_VERSION"
echo "Releasing version $version merging from $src -> $targ"
echo "-------------------------------------------------------------------------"

# Ensure working directory in version branch clean
git update-index -q --refresh
if ! git diff-index --quiet HEAD --; then
  echo "Working directory not clean, please commit your changes first"
  exit
fi

# Checkout master branch and merge test branch into master
git checkout $targ
git pull 

#Ensure src branch is updated with master branch
COMMIT_AHEAD_CNT = git rev-list --count master..develop
if [ COMMIT_AHEAD_CNT -gt 0 ]; then
  echo "$src branch is $COMMITS_COUNT behind $targ. Please update $src branch with $targ branch"
  echo "Aborting"
  exit
fi
git merge $src --no-ff --no-edit

# Revert the changes and exit if conflicts exists
CONFLICTS=$(git ls-files -u | wc -l)
echo "Conflicts $CONFLICTS"
if [ "$CONFLICTS" -gt 0 ] ; then
   echo "There is a merge conflict. Please update $src branch with $targ branch and resolve conflicts."
   echo "Aborting"
   git merge --abort
   git checkout $src
   exit 1
fi

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