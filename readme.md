# Script for making a backup of a user/organisations Github repos with commit history

This script allows a user to backup repos with commit history from organisations/users and compress them into a single zip archive

# Running the script

Dependancies:
```
jq git zip
```
1. Replace `<your access token>` with your access token from https://github.com/settings/tokens Token only needs repo and org read permisions.
2. Replace `<your github user>` with your github user and set `cloneUserRepos=` to `true` if your cloning a users repos or Replace `<Your organiasation>` with a org name and set `cloneOrgRepos=` to `true`. It is possible to set both to `true` this will clone both the user and the orgs repo into seperate folders in a single .zip 

3. Run the script with you might need to set the script to executable with `chmod +x ./cloneall.sh` 
  ```
  ./cloneall.sh
  ```

# Restore a repo from a bundle file 
Restore notes borrowed from https://gist.github.com/xtream1101/fd79f3099f572967605fab24d976b179 

Here we will restore the repo from the bundle and create a new remote origin that will contain all brnaches and tags
1. Clone the repo from the bundle
  ```
  git clone vuejs_vue.bundle
  ```
2. Get all the branches locally to be pushed up to your origin later (from: https://gist.github.com/grimzy/a1d3aae40412634df29cf86bb74a6f72)
  ```
  git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
  git fetch --all
  git pull --all
  ```
3. Create a new repo on your git server and update the origin of the local repo
  ```
  git remote set-url origin git@github.com/xtream1101/test-backup.git
  ```
4. Push all branches and tags to the new remote origin
  ```
  git push --all
  git push --tags
  ```