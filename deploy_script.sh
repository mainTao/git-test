#!/usr/bin/env bash
app_name='git-test' # NOTICE: modify the app name to your self

set -e # Exit immediately if a command exits with a non-zero status.

echo "NODE_ENV: $NODE_ENV"
tag=$1
echo "tag: $tag"

branch='master' # master is default branch
if [ $NODE_ENV == 'development' ]
then
    branch='develop'
fi

echo "branch: $branch"

## Get source code
git fetch --all --tags --prune
git checkout $branch
if [ $tag ]; then
    echo "Use tag $tag"
    git reset --hard tags/$tag
else
    echo "Use latest code"
    git reset --hard origin/$branch
fi

## Install dependencies, try cnpm first
cnpm install || npm install

set +e # Not exit even error

echo "Restarting $app_name"
pm2 restart $app_name
if [ $? -ne 0 ]; then
    echo "Restart failed, delete then start"
    pm2 delete $app_name
    pm2 start index.js -n $app_name
fi

if [ $? -ne 0 ]; then
    echo "Fatal Error!"
else
    echo "Congrats! Try these commands:\n\
    pm2 show $app_name\n\
    pm2 logs $app_name"
fi
