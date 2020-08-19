#!/usr/bin/env bash

version=$(grep -Po '"packageVersion":.*?[^\\]",' generator/languages/dotnet/openapi-generator-config.json | cut -c20-24)
pr_number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")

cd sdk

git config user.email $USER_EMAIL
git config user.name $USER

branch_name="feat/sdk/generator-pr-$pr_number"
remote_branch_check=$(git ls-remote --heads origin $branch_name)

if [ -z "$remote_branch_check" ]
then
  echo "new branch"
  git checkout -b $branch_name
  rm -r Engines
  cp -r ../generator/languages/dotnet/sdk Engines
  git status
  if git diff-index --quiet HEAD -- 
  then 
    echo "No changes to commit." 
  else
    git add -A .
    git commit -m "feat(sdk): Auto-commit by Generator PR $pr_number for SDK version v$version"
    echo "Committed all the changes"
    
    git push origin $branch_name
    echo "Pushed all the changes to remote location"
    
    export GITHUB_USER=$USER
    export GITHUB_TOKEN=$USER_API_KEY
    hub pull-request -m "feat(sdk): Auto-created by Generator PR $pr_number" -h $branch_name
  fi
else
  echo "branch exists"
  git checkout $branch_name
  git pull
  rm -r Engines
  cp -r ../generator/languages/dotnet/sdk Engines
  git status
  if git diff-index --quiet HEAD -- 
  then 
    echo "No changes to commit." 
  else 
    git add -A .
    git commit -m "feat(sdk): Auto-commit by Generator PR $pr_number for SDK version v$version"
    echo "Committed all the changes"
  
    git push origin $branch_name
    echo "Pushed all the changes to remote location"
  fi
fi         