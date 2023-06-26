#!/bin/bash
# requires jq -> https://stedolan.github.io/jq/download/;
# create oath token -> https://github.com/settings/tokens;

# GitHub configuration
githubToken="<your access token>"  
githubUser="<your github user>"
githubOrganization="<Your organiasation>"

# Script configuration
targetDir="./repos-$(date +"%Y-%m-%d")"
cloneOrgRepos=true
cloneUserRepos=false
targetField="clone_url"
startDir="$(pwd)"

# Script
mkdir -p $targetDir
cd $targetDir
echo "PWD: $(pwd)"

# https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-organization-repositories
listOrgReposUrl="https://api.github.com/orgs/$githubOrganization/repos?per_page=100"
if $cloneOrgRepos
then
    orgRepositories=$(curl $listOrgReposUrl -u ${githubUser}:${githubToken} | jq -r .[].${targetField})
else
    orgRepositories=""
fi

# https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-repositories-for-the-authenticated-user
listUserRepoUrl="https://api.github.com/user/repos?per_page=100&type=owner"
if $cloneUserRepos
then
    userRepositories=$(curl $listUserRepoUrl -u ${githubUser}:${githubToken} | jq -r .[].${targetField})
else
    userRepositories=""
fi

# Clone all repositories
repositories="$orgRepositories $userRepositories"
for repository in $repositories
do
    printf "\nRepository found: $repository\n"
    repo="${repository##*/}"
    repo="${repo%.*}"
    echo "$repo"
    echo "$repository"
    mkdir "$repo" 
    cd "$repo"
    git clone --mirror "$repository" . 
    for branch in `git branch -a | grep remotes | grep -v HEAD | grep -v master `; 
    do
        git branch --track ${branch#remotes/origin/} $branch || git branch
    done
    echo "PWD: $(pwd)"
    git bundle create ./$repo.bundle --all 
    git bundle verify ./$repo.bundle
    cd ../
done

cd "$startDir"
zip -r -m -9 "repo-archive-$(date +"%Y-%m-%d").zip" "$targetDir"