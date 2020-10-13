#! /bin/sh

set -e

build_branch="build"
source_branch="master"

hakyll_bin="site"

echo "### building site... ###"
stack build
stack exec "${hakyll_bin}" build

echo "### deployment ###"
git checkout "${build_branch}"
rsync -v -a --delete-after --exclude=".git/" _site/ ./
touch ".nojekyll"

git add .
git commit -m "deploy"
git push origin HEAD

git checkout "${source_branch}"
