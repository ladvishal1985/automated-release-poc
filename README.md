# Automate merge and tagging flow git

We often need require a a merge from develop to test(release for regression) or from test to master (production release). This process often involves many manual steps of running various git command from checking out of source branch to merge and update the tag. This is a sample script to help developer to do an automated merge to source branch. This script can act as a reference script for automating your merge process. 

## Usage

Assuming you have a two step process for  release and 3 branches(develop, test, master) to work 

### Release for Regression

Merge to test branch for regression.
./release.sh develop test regression 1.0.3

### Release to production by updating Tag

Merge and that you make new tag on master branch the script will do merge from develop to master push a new tag named as the version they correspond to, e.g. 1.0.3
./release.sh test master tag
