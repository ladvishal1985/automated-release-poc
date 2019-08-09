#!/usr/bin/env bash

# Assuming you have a master and test branch, and that you make new
# tag on master branch the script will do merge from develop to master 
# push a new tag named as the version they correspond to, e.g. 1.0.3
# Usage: ./release.sh 1.0.3 test master

# Get version argument and verify
version=$1 
src=$2
targ=$3


# Step 1: Validate if paramters are pass appropriately
if [ -z "$version" ] || [ -z "$src" ] || [ -z "$targ" ]; then
  echo "Please specify appropriate version, source branch and target branch"
  exit
fi



# Step 2: Get version from package.json and display info 
PKG_VERSION=$(node -pe "require('./package.json').version")
echo "Current Application version is $PKG_VERSION"
echo "Releasing version for regression is $version. Merging from $src -> $targ"
echo "-------------------------------------------------------------------------"

# Step 3: Ensure working directory in version branch clean
git update-index -q --refresh
if ! git diff-index --quiet HEAD --; then
  echo "Working directory not clean, please commit your changes first"
  exit
fi

# Step 4: Checkout test branch and get latest code
git checkout $targ
git pull 

# Step 4: Check if target branch is not ahead of source branch
COMMIT_AHEAD_CNT = git rev-list --count $targ..$src
if [ COMMIT_AHEAD_CNT -gt 0 ]; then
  echo "$src branch is $COMMITS_COUNT behind $targ. Please update $src branch with $targ branch"
  echo "Aborting"
  exit
fi

# Step 5: Merge develop branch into test and update the version
git merge $src --no-ff --no-edit
npm --no-git-tag-version $version 
git push

# Step 6: Revert the changes and exit if conflicts exists
CONFLICTS=$(git ls-files -u | wc -l)
echo "Conflicts $CONFLICTS"
if [ "$CONFLICTS" -gt 0 ] ; then
   echo "There is a merge conflict. Please update $src branch with $targ branch and resolve conflicts."
   echo "Aborting"
   git merge --abort
   git checkout $src
   exit 1
fi

# Step 7: Get changes from target branch to source to ensure we have the version.
git checkout $src
git merge $targ --no-ff --no-edit
git push


# Success
echo "-------------------------------------------------------------------------"
echo "Release for regression with $version complete"