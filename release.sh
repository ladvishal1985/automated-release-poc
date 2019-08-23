#!/usr/bin/env bash

# Assuming you have a master and test branch, and that you make new
# tag on master branch the script will do merge from develop to master
# push a new tag named as the version they correspond to, e.g. 1.0.3
# Usage:
# # # Regression: ./release.sh develop test regression 1.0.3
# # # Tag: ./release.sh test master tag

# Get version argument and verify
src=${1:-develop}
targ=${2:-test}
release=${3:-regression}
version=$4
d=$(date +%m/%d/%Y) # Get today's date

echo $version $release $src $targ

# Step 1: Validate if paramters are pass appropriately
if [ -z "$src" ] || [ -z "$targ" ]; then
  echo "Please specify appropriate source branch and target branch"
  exit
fi
if [ -z "$version" ] && [ "$release" = "regression" ]; then
  echo "Please specify appropriate version"
  exit
fi

# Step 2: Get version from package.json and display info
PKG_VERSION=$(node -pe "require('./package.json').version")
if [ $(git tag -l "$version") ]; then
  echo "The $version tag already exists. Please try another tag!"
  exit
fi
echo "Current Application version is $PKG_VERSION"
echo "Releasing version for regression is $version. Merging from $src -> $targ"
echo "-------------------------------------------------------------------------"

echo "Ensure working directory in version branch clean"
git update-index -q --refresh
if ! git diff-index --quiet HEAD --; then
  echo "Working directory not clean, please commit your changes first"
  exit
fi

echo "Checkout test branch and get latest code"
git checkout $src
git pull
git checkout $targ
git pull

echo "Check if target branch is not ahead of source branch"
COMMIT_AHEAD_CNT=$(git rev-list --count $src..$targ)
echo "$src branch is $COMMIT_AHEAD_CNT commits behind $targ."
if [ "$COMMIT_AHEAD_CNT" -gt 0 ]; then
  echo "Please update '"$src"' branch with '"$targ"' branch"
  echo "Aborting"
  git checkout $src
  exit
fi

echo "Merge develop branch into test and update the version"
git merge $src --no-ff --no-edit
CONFLICTS=$(git ls-files -u | wc -l)
echo "Conflicts $CONFLICTS"
if [ "$CONFLICTS" -gt 0 ]; then
  echo "Revert the changes and exit if conflicts exists"
  echo "There is a merge conflict. Please update '"$src"' with $'"$targ"' branch and resolve conflicts."
  echo "Aborting"
  git merge --abort
  git checkout $src
  exit 1
fi

npm --no-git-tag-version version $version
git add .
git commit -m "Updated the version to $version"
git push
echo "Merge from '"$src"' to '"$targ"' successfull!"

if [ "$release" = "tag" ]; then
  echo "Create a tag on master once merge is success"
  git checkout $targ # Here $targ should be a master branch
  git tag "v$PKG_VERSION" -m "Code Freeze $d"
  git push --tags
  echo "New Tag created!"
fi

echo "Get changes from target branch to source to ensure we have the version."
git checkout $src
git merge $targ --no-ff --no-edit
git push
echo "Merge from '"$targ"' to '"$src"' successfull!"

echo "-------------------------------------------------------------------------"
echo "Release for regression with $version complete"
